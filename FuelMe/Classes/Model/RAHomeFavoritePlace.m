//
//  RAHomeFavoritePlace.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAHomeFavoritePlace.h"

@implementation RAHomeFavoritePlace

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Home";
        self.blackIconName = @"addressHomeBlack";
        self.grayIconName = @"address-home-icon";
    }
    return self;
}

@end
