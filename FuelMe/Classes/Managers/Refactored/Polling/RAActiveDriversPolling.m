//
//  RAActiveDriversPolling.m
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAActiveDriversPolling.h"

static NSTimeInterval kActiveDriversPollingInterval = 5;

@implementation RAActiveDriversPolling

- (instancetype)initWithDispatchBlock:(GCDBlock)callback {
    GCDQueue serialQueue = createQueue("ActiveDriversSerialQueue", YES, QOS_CLASS_UTILITY);
    self = [super initWithTimeInterval:kActiveDriversPollingInterval queue:serialQueue andExecutionBlock:callback];
    if (self) {
        
    }
    return self;
}

@end
