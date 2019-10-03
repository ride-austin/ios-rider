//
//  ConfigLiveLocation.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigLiveLocation.h"

@implementation ConfigLiveLocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return  @{
              @"enabled"  : @"enabled",
              @"expirationTime" : @"expirationTime",
              @"requiredAccuracy" : @"requiredAccuracy"
            };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        if (![_requiredAccuracy isKindOfClass:[NSNumber class]]) {
            _requiredAccuracy = @(70);
        }
        if (![_expirationTime isKindOfClass:[NSNumber class]]) {
            _expirationTime = @(5);
        }
    }
    return self;
}

@end

@implementation CLLocation (ValidLiveLocation)

- (BOOL)isValidLiveLocationBasedOnConfig:(ConfigLiveLocation *)config {
    return config.enabled && self.horizontalAccuracy <= config.requiredAccuracy.doubleValue;
}

- (BOOL)shouldUpdateBasedOnConfig:(ConfigLiveLocation *)config andLastUpdate:(NSDate *)lastLocationUpdate {
    if (lastLocationUpdate == nil) {
        return config.enabled;
    } else {
        BOOL canUpdate = [self.timestamp timeIntervalSinceDate:lastLocationUpdate] + 1 > config.expirationTime.doubleValue;
        return config.enabled && canUpdate;
    }
}

@end
