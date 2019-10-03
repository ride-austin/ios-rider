//
//  DSCarIsAddedViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/15/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSCarIsAddedViewModel.h"

@implementation DSCarIsAddedViewModel

- (NSString *)headerText {
    return @"Vehicle Information";
}

- (NSString *)subtitle {
    return self.config.cityDetail.addCarSuccessMessage;
}

@end
