//
//  ConfigUnpaidBalance.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigUnpaidBalance.h"

@implementation ConfigUnpaidBalance

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"enabled"        : @"enabled",
              @"title"          : @"title",
              @"subtitle"       : @"subtitle",
              @"iconSmallURL"   : @"iconSmallURL",
              @"iconLargeURL"   : @"iconLargeURL",
              @"warningMessage" : @"warningMessage"
            };
}

- (instancetype)init {
    if (self = [super init]) {
        _warningMessage = @"Check pending balance";
    }
    return self;
}

@end
