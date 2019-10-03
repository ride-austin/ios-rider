//
//  DSLicenseViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSLicenseViewModel.h"

@implementation DSLicenseViewModel

- (NSString *)headerText {
    return @"Driver License";
}

- (NSString *)validationMessage {
    return @"Please upload a License Photo to continue.";
}

- (NSString *)validationDateMessage {
    return @"Please select a valid expiration date";
}

- (void)saveImage:(UIImage *)image {
    [super saveImage:image forKey:kDriverLicense];
}

- (UIImage *)cachedImage {
    return [self.cache imageFromCacheForKey:kDriverLicense];
}

@end
