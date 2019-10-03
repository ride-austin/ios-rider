//
//  DBRideStubGenerator.m
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DBRideStubGenerator.h"
#import "DBRideDataModel.h"
#import "DBDriverLocationDataModel.h"
#import "NSDictionary+JSON.h"
#import "TestConfigurationManager.h"
#import "RANetworkManager.h"
#import "RAMacros.h"

@interface DBRideStubGenerator()

//Configuration
@property (nonatomic, strong) DBRideStubConfiguration *configuration;

//Brief: Ride to generate
@property (nonatomic) DBRideDataModel *ride;
@property (nonatomic) NSArray<DBDriverLocationDataModel *>*locations;
@property (nonatomic, assign) BOOL shouldForceRideMockStatus;
@property (nonatomic) NSUInteger currentRideResource;
@property (nonatomic) NSDate *rideCreationDate;

//Injections
@property (nonatomic, strong) NSMutableArray<DBRideStubInjection*> *injectionsQueue;

-(BOOL)shouldResubmit;
-(void)loadNextRideWithInjections:(NSArray<DBRideStubInjection*>*)injections;
-(void)loadRideFromResource:(NSString*)fileName;
-(void)loadDriverLocationsFromResource:(NSString*)fileName;

@end

@interface DBRideStubGenerator (Injection)

-(BOOL)shouldInject:(DBRideStubInjection*)injection atTime:(NSInteger)time withStatus:(MockRideStatus)status;
-(NSNumber*)totalDelayForInjection:(DBRideStubInjection*)injection;
-(void)createSortedInjectionArrayFromArray:(NSArray<DBRideStubInjection*> *)injections;
-(NSArray<NSDictionary*>*)injectionsAtTime:(NSUInteger)time withRideStatus:(MockRideStatus)rideStatus;

@end

@implementation DBRideStubGenerator

+ (instancetype)shared {
    static DBRideStubGenerator *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentRideResource = -1;
    }
    return self;
}

- (void)configureData {
    self.configuration = [[[TestConfigurationManager sharedManager] configuration] rideConfiguration];
    [MockRideResponseModel resetInjections];
    
    [self loadNextRideWithInjections:self.configuration.injections];
    self.rideCreationDate = self.ride.createdDate;
    [self loadDriverLocationsFromResource:@"DBDriverLocationShortData"];
}

static NSUInteger locationIndex = 0;
- (NSDictionary *)rideDictionaryAtTime:(NSUInteger)time {
    DBDriverLocationDataModel *location = self.locations[locationIndex];
    NSUInteger locationsCount = self.locations.count;
    MockRideStatus status = self.shouldForceRideMockStatus ? self.forceRideMockStatus : [self statusBasedOnTime:time];
    locationIndex = (locationIndex + 1) % locationsCount;
    
    NSArray *injections = [self injectionsAtTime:time withRideStatus:status];
    DBLog(@"injections at time %lu with status %lu: %@",(unsigned long)time,(unsigned long)status,injections);
    return [MockRideResponseModel dictionaryWithRide:self.ride status:status location:location injections:injections];
}

- (MockRideStatus)statusBasedOnTime:(NSUInteger)time {
    if (time < self.ride.secondsAccepted) {
        return MockRideStatusRequested;
    } else if (time < self.ride.secondsReached) {
        return MockRideStatusDriverAssigned;
    } else if (time < self.ride.secondsStartedTrip) {
        return MockRideStatusDriverReached;
    } else if (time < self.ride.secondsCompleted) {
        return MockRideStatusActive;
    } else if (time < self.ride.secondsCancelled) {
        return self.configuration.statusBeforeCancelled;
    } else {
        if ([self shouldResubmit]) {
            locationIndex = 0;
            [self loadNextRideWithInjections:self.configuration.injections];
            self.ride.createdDate = self.rideCreationDate;
            return MockRideStatusRequested;
        }
        else if (self.ride.secondsCancelled > 0){
            return self.configuration.whoCancells;
        }
        else {
            return MockRideStatusCompleted;
        }
    }
}

- (void)setForceRideMockStatus:(MockRideStatus)forceRideMockStatus {
    _forceRideMockStatus = forceRideMockStatus;
    self.shouldForceRideMockStatus = YES;
}

-(BOOL)shouldResubmit{
    return self.currentRideResource < (self.configuration.resourceFiles.count-1);
}

-(void)loadNextRideWithInjections:(NSArray<DBRideStubInjection *> *)injections{
    NSArray<NSString*> *resourceFiles = self.configuration.resourceFiles;
    NSUInteger count = resourceFiles.count;
    if (count > 0) {
        self.currentRideResource++;
        NSUInteger index = self.currentRideResource%count;
        NSString *fileName = resourceFiles[index];
        [self loadRideFromResource:fileName];
        if (injections.count > 0) {
            [self createSortedInjectionArrayFromArray:injections];
        }

    }
}

-(void)loadRideFromResource:(NSString *)fileName{
    NSError *error = nil;
    NSDictionary *jsonRide = [NSDictionary jsonFromResourceName:fileName error:&error];
    NSAssert(error == nil, @"%@ failed: %@", fileName,error);
    self.ride = [MTLJSONAdapter modelOfClass:DBRideDataModel.class fromJSONDictionary:jsonRide error:&error];
    NSAssert(error == nil, @"DBRideDataModel failed: %@",error);
}

-(void)loadDriverLocationsFromResource:(NSString *)fileName{
    NSError *error = nil;
    NSArray *jsonDriverLocations = [NSDictionary jsonFromResourceName:fileName error:&error];
    NSAssert(error == nil, @"%@ failed: %@", fileName, error);
    self.locations = [MTLJSONAdapter modelsOfClass:DBDriverLocationDataModel.class fromJSONArray:jsonDriverLocations error:&error];
    NSAssert(error == nil, @"DBDriverLocationDataModel failed: %@",error);
}

- (void)addInjection:(DBRideStubInjection *)rideStubInjection {
    [self.injectionsQueue addObject:rideStubInjection];
}

#pragma mark - Environment

+ (CGFloat)speed {
    return 2;
}

+ (NSNumber *)rideID {
    return [DBRideStubGenerator shared].ride.modelID;
}

@end

#pragma mark - Injection

@implementation DBRideStubGenerator (Injection)

-(BOOL)shouldInject:(DBRideStubInjection *)injection atTime:(NSInteger)time withStatus:(MockRideStatus)status{
    return (status >= injection.injectAfterStatus && time >= injection.totalDelay);
}

-(NSNumber*)totalDelayForInjection:(DBRideStubInjection*)injection{
    NSInteger totalDelay = NSNotFound;
    
    //Other states are not handled because it has no sense to inject after ride has disappear
    switch (injection.injectAfterStatus) {
        case MockRideStatusDriverAssigned:
            totalDelay = self.ride.secondsAccepted + injection.delay;
            break;
        case MockRideStatusDriverReached:
            totalDelay = self.ride.secondsReached + injection.delay;
            break;
        case MockRideStatusActive:
            totalDelay = self.ride.secondsStartedTrip + injection.delay;
            break;
            
        default:
            break;
    }
    
    return [NSNumber numberWithInteger:totalDelay];
}

-(void)createSortedInjectionArrayFromArray:(NSArray<DBRideStubInjection *> *)injections{
    NSAssert(self.ride!=nil, @"Need a ride to create injections!");
    
    NSArray *injectionsSorted = [injections sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DBRideStubInjection *inj1 = (DBRideStubInjection*)obj1;
        DBRideStubInjection *inj2 = (DBRideStubInjection*)obj2;
        
        NSNumber *totalDelay1 = [self totalDelayForInjection:inj1];
        NSNumber *totalDelay2 = [self totalDelayForInjection:inj2];
        
        inj1.totalDelay = totalDelay1.integerValue;
        inj2.totalDelay = totalDelay2.integerValue;
        
        return [totalDelay1 compare:totalDelay2];
    }];
    
    self.injectionsQueue = [NSMutableArray arrayWithArray:injectionsSorted];
}

-(NSArray<NSDictionary *> *)injectionsAtTime:(NSUInteger)time withRideStatus:(MockRideStatus)rideStatus{
    NSMutableArray *rideObjectInjections = [NSMutableArray array];
    NSMutableArray *allInjectionsToBeRemoved = [NSMutableArray array];
    BOOL canBeInjected = YES;
    NSUInteger i = 0;
    while (canBeInjected && i<self.injectionsQueue.count) {
        DBRideStubInjection *injection = self.injectionsQueue[i];
        if ((canBeInjected = [self shouldInject:injection atTime:time withStatus:rideStatus])) {
            if (injection.jsonDict) {
                [rideObjectInjections addObject:injection.jsonDict];
                [allInjectionsToBeRemoved addObject:injection];
            }
            else if (injection.injectionType == DBRITNoNetwork) {
                [[RANetworkManager sharedManager] simulateNetworkStatus:RASimNetUnreachableStatus];
                if (injection.timeout > 0) {
                    [[RANetworkManager sharedManager] performSelector:@selector(disableNetworkStatusSimualation) withObject:nil afterDelay:injection.timeout];
                }
                [allInjectionsToBeRemoved addObject:injection];
            }
        }
        i++;
    }

    if (allInjectionsToBeRemoved.count > 0) {
        NSMutableArray *queue = [NSMutableArray arrayWithArray:self.injectionsQueue];
        for (DBRideStubInjection *injectionToRemove in allInjectionsToBeRemoved) {
            [queue removeObject:injectionToRemove];
        }
        self.injectionsQueue = queue;
        return [NSArray arrayWithArray:rideObjectInjections];
    }
    
    return nil;
}

@end
