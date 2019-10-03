//
//  RASplitFarePolling.m
//  Ride
//
//  Created by Kitos on 25/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RASplitFarePolling.h"

static NSTimeInterval kSplitFarePollingInterval = 2;

@implementation RASplitFarePolling

- (instancetype)initWithDispatchBlock:(GCDBlock)callback {
    self = [super initWithTimeInterval:kSplitFarePollingInterval queue:getUtilityQueue() andExecutionBlock:callback];
    if (self) {
        
    }
    return self;
}

@end
