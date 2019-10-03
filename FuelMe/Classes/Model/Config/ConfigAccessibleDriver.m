//
//  ConfigAccessibleDriver.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigAccessibleDriver.h"

@implementation ConfigAccessibleDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"isEnabled" : @"enabled",
              @"phoneNumber" : @"phoneNumber",
              @"title" : @"title"
            };
}

@end
