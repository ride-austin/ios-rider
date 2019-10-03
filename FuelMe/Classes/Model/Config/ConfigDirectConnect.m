//
//  ConfigDirectConnect.m
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigDirectConnect.h"

@implementation ConfigDirectConnect

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"actionTitle" : @"actionTitle",
              @"connectDescription" : @"description",
              @"placeholder" : @"placeholder",
              @"title" : @"title",
              @"isEnabled" : @"enabled"
            };
}

@end
