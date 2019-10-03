//
//  DSCar.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSCar.h"

@implementation DSCar

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modelID" : @"id",
             @"color" : @"color",
             @"license" : @"license",
             @"make" : @"make",
             @"model" : @"model",
             @"year" : @"year"
             };
}

@end
