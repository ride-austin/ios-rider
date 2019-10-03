//
//  DSCarInfoViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/15/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSCarInfoViewModel.h"

@implementation DSCarInfoViewModel

- (NSString *)headerText {
    return @"Vehicle Information";
}

- (NSArray<NSString *> *)requirements {
    return self.config.cityDetail.requirements;
}

- (NSString *)cityDescription {
    return self.config.cityDetail.cityDescription;
}
@end
