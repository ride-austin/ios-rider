//
//  ConfigUTPayWithBevoBucks.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigUTPayWithBevoBucks.h"

@implementation ConfigUTPayWithBevoBucks

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"enabled" :@"enabled",
              @"iconLargeUrl" : @"iconLargeUrl",
              @"ridePaymentDelay" :@"ridePaymentDelay",
              @"shortDescription" :@"description",
              @"splitfareMessage" :@"splitfareMessage",
              @"availableForSplitfare" : @"availableForSplitfare"
            };
}

@end
