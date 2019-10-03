//
//  DSCarInsuranceViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSCarInsuranceViewModel.h"

@implementation DSCarInsuranceViewModel

- (NSString *)headerText {
    return @"Insurance";
}

- (NSString *)validationMessage {
    return @"Please upload an Insurance Photo to continue.";
}

- (NSString *)validationDateMessage {
    return @"Please select a valid expiration date";
}

- (void)saveImage:(UIImage *)image {
    [super saveImage:image forKey:kCarInsurance];
}

- (UIImage *)cachedImage {
    return [self.cache imageFromCacheForKey:kCarInsurance];
}

@end
