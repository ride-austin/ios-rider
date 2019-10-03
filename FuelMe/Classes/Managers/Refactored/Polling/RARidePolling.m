//
//  RARidePolling.m
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARidePolling.h"

static NSTimeInterval kRidePollingInterval = 2;

@implementation RARidePolling

- (instancetype)initWithDispatchBlock:(GCDBlock)callback {
    if (self = [super initWithTimeInterval:kRidePollingInterval queue:getUtilityQueue() andExecutionBlock:callback]) {
        
    }
    return self;
}

@end
