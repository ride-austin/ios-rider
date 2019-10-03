//
//  RARideManager.m
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARideManager.h"

#import "LocationService.h"
#import "RACacheManager.h"
#import "RARideAPI.h"
#import "RARideCommentsManager.h"
#import "RARidePolling.h"
#import "RASessionManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NSError+ErrorFactory.h"
NSString *const kNeedCompleteRideErrorDomain = @"com.rideaustin.error.reloadRide";

#pragma mark - KVO Keys
NSString *const kRAObservationNewValue = @"new";
NSString *const kRAObservationOldValue = @"old";
NSString *const kRAObservationKeyPath = @"FBKVONotificationKeyPathKey";
NSString *const kRAKeyPathObserveCurrentRide = @"currentRide";
NSString *const kRAKeyPathObserveCurrentRideStatus = @"status";
NSString *const kRAKeyPathObserveCurrentRideEndLocation = @"observedEndLocation";
NSString *const kRAKeyPathObserveEstimatedCompletionDate  = @"estimatedCompletionDate";
NSString *const kRAKeyPathObservePollingError = @"pollingError";
NSString *const kRAKeyPathObserveActiveDriverLocation = @"location";
NSString *const kRAKeyPathObserveUpgradeRequestStatus = @"upgradeStatus";
NSString *const kRAKeyPathObserveRequestedCarTypeTitle = @"requestedCarType.title";
NSString *const kRAKeyPathObserveActiveDriver = @"activeDriver";
NSString *const kRAKeyPathObserveUpgradeRequest = @"upgradeRequest";
NSString *const kRAKeyPathObservePrecedingRideStatus = @"precedingRide.status";
NSString *const kRAKeyPathObservePrecedingRideEndLocation = @"precedingRide.endLocation";

@interface RARideManager ()

@property (nonatomic, strong) RARideDataModel *currentRide;

@property (nonatomic) NSMutableDictionary<NSString *, FBKVOController *> *observers;
@property (nonatomic) NSMutableDictionary<NSString *, RAKVObserveBlock> *observerHandlers;

@property (nonatomic, strong) RARidePolling *ridePolling;
@property (nonatomic, strong) NSError *pollingError;
@property (nonatomic) BOOL fetchingRideData;
@property (nonatomic, getter=isReloadingRide) BOOL reloadingRide;

@end

@interface RARideManager (Cache)

- (void)saveCurrentRide:(RARideDataModel*)ride;
- (RARideDataModel*)cachedCurrentRide;
- (void)cleanCache;

@end

@interface RARideManager (Private_KVO)

- (void)startObserving;
- (void)stopObserving;

- (void)addActiveDriverObserver;
- (void)removeActiveDriverObserver;
- (void)reloadActiveDriverLocationObserver;
- (void)removeActiveDriverLocationObserver;

- (void)addUpgradeRequestObserver;
- (void)removeUpgradeRequestObserver;
- (void)reloadUpgradeRequestStatusObserver;
- (void)removeUpgradeRequestStatusObserver;

@end

@interface RARideManager (Private_RideEngine)

- (void)createAndResumeRidePolling;
- (void)destroyRidePolling;
- (void)checkRideStatus;

@end

@interface RARideManager (Private)

- (void)setupCurrentRide:(RARideDataModel*)ride;
- (void)sendSynchronizeRideNotification;
- (void)saveContext;

@end

@implementation RARideManager
@synthesize currentRide = _currentRide;

#pragma mark - Lifecycle

+ (RARideManager *)sharedManager {
    static RARideManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RARideManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _fetchingRideData = NO;
        _reloadingRide = NO;
        _observers = [[NSMutableDictionary alloc] init];
        _observerHandlers = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPolling) name:kDidSignoutNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Ride Utils

- (RARideDataModel *)currentRide {
    if (!_currentRide) {
        _currentRide = [self cachedCurrentRide];
    }
    return _currentRide;
}

- (void)setCurrentRide:(RARideDataModel *)currentRide {
    _currentRide = currentRide;
    [self saveCurrentRide:currentRide];
}


- (BOOL)isDriverComing {
    if (self.currentRide) {
        return [self.currentRide isDriverComing];
    }
    return NO;
}

- (BOOL)isDriverArrived {
    if (self.currentRide) {
        return [self.currentRide isDriverArrived];
    }
    return NO;
}

- (BOOL)isOnTrip {
    if (self.currentRide) {
        return [self.currentRide isOnTrip];
    }
    return NO;
}

- (BOOL)isRiding {
    if (self.currentRide) {
        return [self.currentRide isRiding];
    }
    return NO;
}

- (BOOL)isRiding:(RARideStatus)status {
    if (self.currentRide) {
        return [self.currentRide isRiding:status];
    }
    return NO;
}

@end

#pragma mark - Observation

@implementation RARideManager (Observation)

- (void)addObserver:(FBKVOController *)observer withHandler:(RAKVObserveBlock)handler {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)observer.hash];
    self.observers[key] = observer;
    self.observerHandlers[key] = [handler copy];
}

- (void)removeObserver:(FBKVOController *)observer {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)observer.hash];
    [observer unobserveAll];
    [self.observers removeObjectForKey:key];
    [self.observerHandlers removeObjectForKey:key];
}

- (void)addCurrentRideObserver:(FBKVOController *)observer withObservation:(RAKVObserveBlock)handler {
    [observer observe:self keyPaths:@[kRAKeyPathObserveCurrentRide] handler:handler];
}

- (void)removeCurrentRideObserver:(FBKVOController *)observer {
    [observer unobserve:self keyPath:kRAKeyPathObserveCurrentRide];
}

@end

#pragma mark Ride Engine

@implementation RARideManager (RideEngine)

- (void)requestRide:(RARideRequestAbstract *)rideRequest completion:(RARequestRideStatusCodeCompletionBlock)handler {
    __weak RARideManager *weakSelf = self;
    [self removeCurrentRide];
    [RARideAPI requestRide:rideRequest withCompletion:^(NSInteger statusCode, RARideDataModel *ride, NSError *error) {
        weakSelf.currentRide = ride;
        
        if (ride) {
            #ifdef TEST
            #else
            [FBSDKAppEvents logEvent: @"REQUESTED" parameters: @{ @"rideId": ride.modelID }];
            #endif
            
            [weakSelf setupCurrentRide:ride];
        }
        
        if (handler) {
            handler(statusCode, ride, error);
        }
        
    }];
}

- (void)initiateThirdPartyRideFromQueueToken:(NSString *)queueToken completion: (RARequestRideCompletionBlock)completion {
    __weak RARideManager *weakSelf = self;
    if (self.isRiding) {
        completion(nil, NSError.initiatedThirdPartyWhileOnTripError);
        return;
    }
    [self removeCurrentRide];
    [RARideAPI postRidesQueue:queueToken withCompletion:^(RARideDataModel * _Nullable ride, NSError * _Nullable error) {
        weakSelf.currentRide = ride;
        if (ride) {
            #ifdef TEST
            #else
            [FBSDKAppEvents logEvent: @"REQUESTED_FROM_THIRD_PARTY" parameters: @{ @"rideId": ride.modelID }];
            #endif
            [weakSelf setupCurrentRide:ride];
        }
        completion(ride, error);
    }];
}

- (void)reloadRideWithCompletion:(RARequestRideCompletionBlock)handler {
    self.reloadingRide = YES;
    [self stopPolling];
    __weak RARideManager *weakSelf = self;
    [RARideAPI getCurrentRideWithCompletion:^(RARideDataModel *ride, NSError *error) {
        if (ride) {
            weakSelf.currentRide = ride;
            [weakSelf setupCurrentRide:ride];
            if (handler) {
                handler(ride, nil);
            }
        } else if (!error && self.currentRide) {
            //Restore local Ride
            NSString *rideId = weakSelf.currentRide.modelID.stringValue;
            [weakSelf restoreRide:rideId completion:handler];
        } else {
            if (handler) {
                handler(nil, error);
            }
        }
        weakSelf.reloadingRide = NO;
    }];
}

- (void)restoreRide:(NSString *)rideID completion:(RARequestRideCompletionBlock)handler {
    __weak RARideManager *weakSelf = self;
    [RARideAPI getRide:rideID withRiderLocation:[LocationService myValidLocation] andCompletion:^(RARideDataModel *ride, NSError *error) {
        weakSelf.currentRide = ride;
        if (ride) {
            if (![ride isFinished]) {
                [weakSelf setupCurrentRide:ride];
            } else {
                ride = nil;
                error = [NSError errorWithDomain:kNeedCompleteRideErrorDomain code:-1 userInfo:nil];
            }
        } else if (!error) {
            //There is not error neither Ride. Can happen if the ride doesn't belongs to current Rider
            [weakSelf removeCurrentRide];
        }
        
        if (handler) {
            if (ride && ride.status == RARideStatusNoAvailableDriver) {
                //Avoid showing no driver available message while restoring
                handler(nil, nil);
            } else {
                handler(ride, error);
            }
        }
    }];
}

- (void)cancelRideWithId:(NSString *)rideId completion:(void (^)(NSError *))completion {
    __weak RARideManager *weakSelf = self;
    [RARideAPI cancelRideById:rideId withCompletion:^(NSError *error) {
        if (!error) {
            [weakSelf removeCurrentRide];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)removeCurrentRide {
    [self stopPolling];
    [self cleanCache];
    self.currentRide = nil;
}

- (void)stopPolling {
    [self stopObserving];
    [self destroyRidePolling];
    self.fetchingRideData = NO;
}

- (void)pauseRidePolling {
    [self.ridePolling pause];
}

- (void)resumeRidePolling {
    [self checkRideStatus];
    [self.ridePolling resume];
}

@end

#pragma mark - Ride Updates

@implementation RARideManager (RideUpdates)

- (void)updateDestination:(RARideLocationDataModel *)destination completion:(RARideUpdateCompletionBlock)handler {
    [RARideAPI updateDestination:destination
                         forRide:self.currentRide.modelID.stringValue
                      completion:handler];
}

- (void)updateComment:(NSString *)comment completion:(RARideUpdateCompletionBlock)handler {
    [[RARideCommentsManager sharedManager] storeComment:comment forLocation:self.currentRide.startLocation.coordinate];
    [RARideAPI updateComment:comment
                     forRide:self.currentRide.modelID.stringValue
                  completion:handler];
}

@end

#pragma mark - Cache

static NSString *kCurrentRideCacheKey = @"kCurrentRideCacheKey";

@implementation RARideManager (Cache)

- (void)saveCurrentRide:(RARideDataModel *)ride {
    if (ride) {
        [RACacheManager cacheObject:ride forKey:kCurrentRideCacheKey];
    }
}

- (RARideDataModel *)cachedCurrentRide {
    return [RACacheManager cachedObjectForKey:kCurrentRideCacheKey];
}

- (void)cleanCache {
    [RACacheManager removeObjectForKey:kCurrentRideCacheKey];
}

@end

@implementation RARideManager (Private_KVO)

- (void)cleanObservers {
    for (NSString *observerKey in self.observers.allKeys) {
        [self.observers[observerKey] unobserveAll];
    }
}

- (void)startObserving {
    [self cleanObservers];
    
    for (NSString *observerKey in self.observers.allKeys) {
        FBKVOController *observer = self.observers[observerKey];
        RAKVObserveBlock handler = self.observerHandlers[observerKey];
        
        [observer observe:self keyPaths:@[kRAKeyPathObservePollingError] handler:handler];
        [observer observe:self.currentRide keyPaths:@[kRAKeyPathObserveCurrentRideStatus, kRAKeyPathObserveCurrentRideEndLocation, kRAKeyPathObserveRequestedCarTypeTitle] handler:handler];
        [observer observe:self.currentRide.activeDriver keyPaths:@[kRAKeyPathObserveActiveDriverLocation] handler:handler];
        [observer observe:self.currentRide.upgradeRequest keyPaths:@[kRAKeyPathObserveUpgradeRequestStatus] handler:handler];
        [observer observe:self.currentRide keyPaths:@[kRAKeyPathObservePrecedingRideStatus, kRAKeyPathObservePrecedingRideEndLocation, kRAKeyPathObserveEstimatedCompletionDate] handler:handler];
    }
    
    [self addActiveDriverObserver];
    [self addUpgradeRequestObserver];
}

- (void)stopObserving {
    [self removeActiveDriverObserver];
    [self removeUpgradeRequestObserver];
    [self cleanObservers];
}

- (void)addActiveDriverObserver {
    [[self KVOController] observe:self.currentRide
                          keyPath:kRAKeyPathObserveActiveDriver
                          options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                            block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                RAActiveDriverDataModel *aDriver = change[kRAObservationNewValue];
                                if (aDriver) {
                                    [self reloadActiveDriverLocationObserver];
                                } else {
                                    [self removeActiveDriverLocationObserver];
                                }
                            }
     ];
}

- (void)removeActiveDriverObserver {
    [[self KVOController] unobserve:nil keyPath:kRAKeyPathObserveActiveDriver];
}

- (void)reloadActiveDriverLocationObserver {
    for (NSString *observerKey in self.observers.allKeys) {
        FBKVOController *observer = self.observers[observerKey];
        RAKVObserveBlock handler = self.observerHandlers[observerKey];
        [observer observe:self.currentRide.activeDriver keyPaths:@[kRAKeyPathObserveActiveDriverLocation] handler:handler];
    }
}

- (void)removeActiveDriverLocationObserver {
    for (NSString *observerKey in self.observers.allKeys) {
        FBKVOController *observer = self.observers[observerKey];
        [observer unobserve:nil keyPath:kRAKeyPathObserveActiveDriverLocation];
    }
}

- (void)addUpgradeRequestObserver {
    [[self KVOController] observe:self.currentRide
                          keyPath:kRAKeyPathObserveUpgradeRequest
                          options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                            block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                RARideUpgradeRequestDataModel *upgradeRequest = change[kRAObservationNewValue];
                                
                                if (upgradeRequest) {
                                    [self reloadUpgradeRequestStatusObserver];
                                } else {
                                    [self removeUpgradeRequestStatusObserver];
                                }
                                
                                for (RAKVObserveBlock observerBlock in self.observerHandlers.allValues) {
                                    observerBlock(observer, change);
                                }
                            }
     ];
}

- (void)removeUpgradeRequestObserver {
    [[self KVOController] unobserve:nil keyPath:kRAKeyPathObserveUpgradeRequest];
}

- (void)reloadUpgradeRequestStatusObserver {
    for (NSString *observerKey in self.observers.allKeys) {
        FBKVOController *observer = self.observers[observerKey];
        RAKVObserveBlock handler = self.observerHandlers[observerKey];
        [observer observe:self.currentRide.upgradeRequest keyPaths:@[kRAKeyPathObserveUpgradeRequestStatus] handler:handler];
    }
}

- (void)removeUpgradeRequestStatusObserver {
    for (NSString *observerKey in self.observers.allKeys) {
        FBKVOController *observer = self.observers[observerKey];
        [observer unobserve:nil keyPath:kRAKeyPathObserveUpgradeRequestStatus];
    }
}

@end

#pragma mark - RideEngine

@implementation RARideManager (Private_RideEngine)

- (void)createAndResumeRidePolling {
    if (!self.ridePolling) {
        self.ridePolling = [[RARidePolling alloc] initWithDispatchBlock:^{
            [self checkRideStatus];
        }];
    }
    [self resumeRidePolling];
}

- (void)destroyRidePolling {
    self.ridePolling = nil;
}

- (void)checkRideStatus {
    if (!self.fetchingRideData && self.ridePolling && self.ridePolling.isExecuting) { //Check if ridePolling exists because if not it means we have to stop polling and then any enqueued request should fail.
        self.fetchingRideData = YES;
        
        __weak RARideManager *weakSelf = self;
        [RARideAPI getRide:self.currentRide.modelID.stringValue withRiderLocation:[LocationService myValidLocation] andCompletion:^(RARideDataModel *ride, NSError *error) {
            
            if (!weakSelf.ridePolling.isExecuting) {
                weakSelf.fetchingRideData = NO;
                return;
            }
            
            if (weakSelf.ridePolling && ![weakSelf isReloadingRide]) { //Avoid any completion execution after removing ride polling or while reloading ride.
                if (error) {
                    
                    //Stops polling (if network is unreachable it is started again from LocationVC - this should be restarted from here - and if timeout a synchronization request is sent.)
                    [weakSelf destroyRidePolling];

                    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
                        weakSelf.pollingError = error;
                    } else {
                        //Not only synchronizing if error.code is -1001 (timeout), if network is reachable but there is an error, it means that something is wrong with this endpoint and so it needs resynchronization until it works.
                        [weakSelf sendSynchronizeRideNotification];
                    }
                } else {
                    if ([weakSelf.currentRide updateChanges:ride]) { //Updates all inner properties in deep to send notifications through KVO.
                        [weakSelf saveContext];
                    }
                    
                    if ([ride isFinished]) {
                        [weakSelf removeCurrentRide];
                    }
                }
            }
            weakSelf.fetchingRideData = NO;
        }];
    }
}

@end

#pragma mark - Private

@implementation RARideManager (Private)

- (void)setupCurrentRide:(RARideDataModel *)ride {
    if (![ride isFinished]) {
        self.currentRide = ride;
        [self createAndResumeRidePolling];
        [self startObserving];
    }
}

- (void)sendSynchronizeRideNotification {
    if ([self.pollingConsumerDelegate respondsToSelector:@selector(pollingNeedsSynchronization)]) {
        [self.pollingConsumerDelegate pollingNeedsSynchronization];
    }
}

- (void)saveContext {
    if ([RASessionManager sharedManager].isSignedIn) {
        [self saveCurrentRide:self.currentRide];
    }
}

@end

#pragma mark - Utils

@implementation RARideManager (Utils)

+ (BOOL)rideCoordinate:(CLLocationCoordinate2D)coord isEqualToOtherRideCoordinate:(CLLocationCoordinate2D)otherCoord {
    BOOL equalLat = [RABaseDataModel rideDegrees:coord.latitude isEqualToOtherRideDegrees:otherCoord.latitude];
    BOOL equalLon = [RABaseDataModel rideDegrees:coord.longitude isEqualToOtherRideDegrees:otherCoord.longitude];
    return (equalLat && equalLon);
}

@end
