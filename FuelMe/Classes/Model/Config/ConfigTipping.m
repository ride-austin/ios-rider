//
//  ConfigTipping.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigTipping.h"

@implementation ConfigTipping

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"enabled"        : @"enabled",
            //@"allowableDelay" : @"ridePaymentDelay",
              @"tipLimit"       : @"rideTipLimit"
            };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

@end
