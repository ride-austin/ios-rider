//
//  DSDriverPhotoViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSDriverPhotoViewModel.h"
#import "RADriverAPI.h"
#import "UIImage+Ride.h"

@implementation DSDriverPhotoViewModel

- (NSString *)headerText {
    return @"Your Driver Photo";
}

- (NSString *)confirmationDescription {
    return @"Are you sure your Driver Profile Photo clearly shows your face and eyes without sunglasses?";
}

- (void)saveImage:(UIImage *)image {
    [super saveImage:image forKey:kDriverPhoto];
}

- (UIImage *)cachedImage {
    return [self.cache imageFromCacheForKey:kDriverPhoto];
}

- (NSData *)cachedData {
    return [self.cachedImage compressToMaxSize:300000];
}

- (void)submitDocumentWithDriver:(NSNumber *)driverId withCompletion:(void (^)(NSError * _Nullable))completion {
    [RADriverAPI postPhotoForDriverWithId:driverId.stringValue fileData:self.cachedData andCompletion:^(id responseObject, NSError *error) {
        if (!error) {
            self.isSubmitted = YES;
        }
        completion(error);
    }];
}

@end
