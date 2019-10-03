//
//  DSAddress.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSAddress.h"

@implementation DSAddress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"address" : @"address",
             @"zipCode" : @"zipCode"
             };
}

- (BOOL)isValid {
    NSParameterAssert([self.address isKindOfClass:NSString.class]);
    NSParameterAssert([self.zipCode isKindOfClass:NSString.class]);
    return YES;
}

@end
