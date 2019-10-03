//
//  PushNotificationAPS.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PushNotificationAPS.h"

@implementation PushNotificationAPS

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"alert" : @"alert",
             @"sound" : @"sound"
            };
}

@end
