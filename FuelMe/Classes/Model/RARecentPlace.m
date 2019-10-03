//
//  RARecentPlace.m
//  Ride
//
//  Created by Kitos on 22/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARecentPlace.h"

@implementation RARecentPlace

- (instancetype)init {
    if (self = [super init]) {
        self.blackIconName = @"address-history-icon";
        self.grayIconName = @"address-history-icon";
    }
    return self;
}

@end

@implementation RARecentPlace (Validation)

- (BOOL)isRecentPlaceValid {
    return self.isCoordinateValid
    && [self.name isKindOfClass:[NSString class]]
    && [self.name length] > 0
    && [self.shortAddress isKindOfClass:[NSString class]]
    && [self.shortAddress length] > 0;
}

@end
