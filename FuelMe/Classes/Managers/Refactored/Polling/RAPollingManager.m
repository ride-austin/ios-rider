//
//  RAPollingManager.m
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAPollingManager.h"
#import "RAMacros.h"

@interface RAPollingManager ()

@property (nonatomic, strong) GCDTimer timer;
@property (nonatomic, assign) BOOL isExecuting;

@end

@implementation RAPollingManager

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval andExecutionBlock:(GCDBlock)callback{
    return [self  initWithTimeInterval:interval queue:getDefaultQueue() andExecutionBlock:callback];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval queue:(GCDQueue)queue andExecutionBlock:(GCDBlock)callback{
    if (self = [super init]) {
        self.isExecuting = NO;
        self.timer = createTimer(interval, queue, callback);
    }
    return self;
}

- (void)dealloc{
    cancelTimer(self.timer);
}

- (void)resume{
    @synchronized (self) {
        if (!self.isExecuting) {
            self.isExecuting = YES;
            resumeTimer(self.timer);
        }
    }
}

- (void)pause{
    @synchronized (self) {
        if (self.isExecuting) {
            self.isExecuting = NO;
            suspendTimer(self.timer);
        }
    }
}

#pragma mark - RAPollingProtocol

- (instancetype)initWithDispatchBlock:(GCDBlock)callback{
    DBLog(@"Error - this should be implemented in subclass: %@",self);
    return nil;
}

@end
