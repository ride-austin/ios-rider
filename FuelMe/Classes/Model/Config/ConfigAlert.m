//
//  ConfigAlert.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigAlert.h"

@implementation ConfigAlert

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return  @{
              @"enabled" : @"enabled",
              @"message" : @"message",
              @"actionTitle" : @"actionTitle",
              @"cancelTitle" : @"cancelTitle"
            };
}

@end
