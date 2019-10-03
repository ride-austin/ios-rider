//
//  RARideCancellationTimer.m
//  Ride
//
//  Created by Kitos on 2/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARideCancellationTimer.h"

static NSTimeInterval kRideCancellationUpdateInterval = 1;

@implementation RARideCancellationTimer

- (instancetype)initWithDispatchBlock:(GCDBlock)callback {
    self = [super initWithTimeInterval:kRideCancellationUpdateInterval queue:getUtilityQueue() andExecutionBlock:callback];
    if (self) {
        
    }
    return self;
}


@end
