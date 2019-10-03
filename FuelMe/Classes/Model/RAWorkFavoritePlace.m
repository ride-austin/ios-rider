//
//  RAWorkFavoritePlace.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAWorkFavoritePlace.h"

@implementation RAWorkFavoritePlace

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Work";
        self.blackIconName = @"addressWorkBlack";
        self.grayIconName = @"address-work-icon";
    }
    return self;
}

@end
