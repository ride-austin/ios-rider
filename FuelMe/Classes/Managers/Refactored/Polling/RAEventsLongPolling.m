//
//  RALongPolling.m
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAEventsLongPolling.h"

#import "RACacheManager.h"
#import "RAEventsAPI.h"
#import "RAMacros.h"
#import "RAPollingManager.h"
#import "RARideManager.h"
#import "SystemVersionCompare.h"

@interface RAEventsLongPolling ()

@property (nonatomic, strong) NSString *lastReceivedEventID;
@property (nonatomic, strong) RAPollingManager *authenticatedPolling;
@property (nonatomic, readonly) BOOL canRequestEvents;
@property (nonatomic) BOOL shouldStopPolling;
@property (nonatomic, getter=isWaitingResponse) BOOL waitingResponse;
@property (nonatomic, strong) NSOperationQueue *eventsQueue;

@end

@interface RAEventsLongPolling (Cache)

- (void)saveLastReceivedEventID:(NSString*)eventID;
- (NSString*)getLastReceivedEventID;

@end

@interface RAEventsLongPolling (Polling)

- (void)pollForEvents;
- (void)startPolling;
- (void)stopPolling;

@end

@interface RAEventsLongPolling (Private)

- (void)processReceivedEvents:(NSArray <RAEventDataModel*>*) events;
- (void)processEvent:(RAEventDataModel*)event;

- (void)checkIfAuthenticated;

@end

@implementation RAEventsLongPolling
@synthesize lastReceivedEventID = _lastReceivedEventID;

+ (void)load {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        dispatch_async(getUtilityQueue(), ^{
            [[RAEventsLongPolling sharedManager] startPolling];
        });
    }

    [[RARideManager sharedManager] addCurrentRideObserver:[[RAEventsLongPolling sharedManager] KVOController] withObservation:^(FBKVOController *observer, NSDictionary<NSString *,id> *change) {
        id old = change[kRAObservationOldValue];
        id new = change[kRAObservationNewValue];

        if (IS_NULL2(old) && IS_NOT_NULL(new)) {
            dispatch_async(getUtilityQueue(), ^{
                [[RAEventsLongPolling sharedManager] stopPolling];
            });
        }
        else if (IS_NULL2(new) && IS_NOT_NULL(old)){
            dispatch_async(getUtilityQueue(), ^{
                [[RAEventsLongPolling sharedManager] startPolling];
            });
            
        }
    }];
}

+ (RAEventsLongPolling *)sharedManager {
    static RAEventsLongPolling *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [RAEventsLongPolling new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.shouldStopPolling = NO;
        self.waitingResponse = NO;
        self.eventsQueue = [[NSOperationQueue alloc] init];
        self.eventsQueue.maxConcurrentOperationCount = 1;
        self.eventsQueue.qualityOfService = NSOperationQualityOfServiceUtility;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfAuthenticated) name:kDidSignoutNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSignoutNotification object:nil];
    [self stopPolling];
    [self.authenticatedPolling pause];
    self.authenticatedPolling = nil;
}

- (NSString *)lastReceivedEventID {
    if (!_lastReceivedEventID) {
        _lastReceivedEventID = [self getLastReceivedEventID];
    }
    return _lastReceivedEventID;
}

- (void)setLastReceivedEventID:(NSString *)lastReceivedEventID {
    _lastReceivedEventID = lastReceivedEventID;
    [self saveLastReceivedEventID:lastReceivedEventID];
}

- (BOOL)canRequestEvents {
    return !self.shouldStopPolling && [[RANetworkManager sharedManager] isAuthenticated] && ![[RARideManager sharedManager] isRiding] && ![self isWaitingResponse];
}

@end

#pragma mark - Cache

static NSString *const kLastReceivedEventIDKey = @"kLastReceivedEventIDKey";

@implementation RAEventsLongPolling (Cache)

- (void)saveLastReceivedEventID:(NSString *)eventID {
    [RACacheManager cacheObject:eventID forKey:kLastReceivedEventIDKey];
}

- (NSString *)getLastReceivedEventID {
    return [RACacheManager cachedObjectForKey:kLastReceivedEventIDKey];
}

@end

#pragma mark - Polling

static NSTimeInterval const kCheckIfLoggedTimeInterval = 2;
static NSTimeInterval const kRetryPollingTimeInterval = 2;

@implementation RAEventsLongPolling (Polling)

- (void)pollForEvents {
    if ([self canRequestEvents]){
        self.authenticatedPolling = nil;
        self.waitingResponse = YES;

        [RAEventsAPI getEventsWithLastReceivedEvent:self.lastReceivedEventID copmletion:^(NSArray<RAEventDataModel *> *events, NSError *error) {
            self.waitingResponse = NO;
            
            if (!error) {
                [self processReceivedEvents:events];
                
                dispatch_async(getUtilityQueue(), ^{
                    [self pollForEvents];
                });
            } else {
                DBLog(@"events error: %@",error);

                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kRetryPollingTimeInterval * NSEC_PER_SEC);
                dispatch_after(popTime, getUtilityQueue(), ^(void){
                    [self startPolling];
                });
            }
        }];
    } else if (![[RANetworkManager sharedManager] isAuthenticated]) {
        [self checkIfAuthenticated];
    } else{
        self.authenticatedPolling = nil;
    }
}

- (void)startPolling {
    DBLog(@"start polling events");
    self.shouldStopPolling = NO;
    [self pollForEvents];
}

- (void)stopPolling {
    DBLog(@"stop polling events");
    self.shouldStopPolling = YES;
    [self.eventsQueue cancelAllOperations];
}

@end

#pragma mark Private

NSString *kEventsLongPollingHasReceivedNewEventNotification = @"kEventsLongPollingHasReceivedNewEventNotification";

@implementation RAEventsLongPolling (Private)

- (void)processReceivedEvents:(NSArray<RAEventDataModel *> *)events {
    if (events.count > 0) {
        RAEventDataModel *lastEvent = [events lastObject];
        self.lastReceivedEventID = lastEvent.modelID.stringValue; //maybe the lastReceived event could be set in 'processEvent:' so that if any operation is cancelled, the remaining events can be gotten in the next request but if polling is stopped when started again those events could be not necessary....
        
        for (RAEventDataModel *event in events) {
            NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processEvent:) object:event];
            [self.eventsQueue addOperation:op];
        }
    }
}

- (void)processEvent:(RAEventDataModel *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventsLongPollingHasReceivedNewEventNotification object:event];    
}

- (void)checkIfAuthenticated {
    [self stopPolling];

    __weak RAEventsLongPolling *weakSelf = self;
    self.authenticatedPolling = [[RAPollingManager alloc] initWithTimeInterval:kCheckIfLoggedTimeInterval andExecutionBlock:^{
        //DBLog(@"checkIfLogged");
        if ([[RANetworkManager sharedManager] isAuthenticated]) {
            weakSelf.authenticatedPolling = nil;
            
            dispatch_async(getUtilityQueue(), ^{
                [weakSelf startPolling];
            });
        }
    }];
    
    [self.authenticatedPolling resume];
}

@end
