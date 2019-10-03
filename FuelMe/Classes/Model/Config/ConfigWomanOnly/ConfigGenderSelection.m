//
//  ConfigGenderSelection.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigGenderSelection.h"

@implementation ConfigGenderSelection

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"title" : @"title",
              @"subtitle" : @"subtitle",
              @"options" : @"options"
            };
}

- (instancetype)init {
    if (self = [super init]) {
        _options = @[@"MALE", @"FEMALE"];
    }
    return self;
}

@end
