//
//  DBRideStubConfiguration.m
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DBRideStubConfiguration.h"

@implementation DBRideStubConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.initialTime = -1;
        self.resourceFiles = @[@"DBRideData"];
        self.statusBeforeCancelled = MockRideStatusDriverReached;
        self.whoCancells = MockRideStatusCancelledByDriver;
        self.injections = nil;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"<--\n DBRideConfiguration -\n Initial time: %lu\n resources: %@\n statusBeforeCancelled: %lu\n WhoCancells: %lu\n injections:\n %@ \n-->",(unsigned long)self.initialTime, self.resourceFiles, (unsigned long) self.statusBeforeCancelled, (unsigned long) self.whoCancells, self.injections];
}

@end
