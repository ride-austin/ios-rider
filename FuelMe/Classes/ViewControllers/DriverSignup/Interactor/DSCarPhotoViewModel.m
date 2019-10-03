//
//  DSCarPhotoViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DSCarPhotoViewModel.h"
#import "RADriverAPI.h"
#import "NSString+Ride.h"
#import "UIImage+Ride.h"

@implementation DSCarPhotoViewModel

- (instancetype)initWithType:(CarPhotoType)carPhotoType config:(ConfigRegistration *)config andCache:(SDImageCache *)cache {
    if (self = [super initWithConfig:config andCache:cache]) {
        _carPhotoType = carPhotoType;
    }
    return self;
}

- (NSString *)headerText {
    return @"Vehicle Information";
}

- (NSString *)carPhotoDescription {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return @"Front left angle, showing the license plate";
        case BackPhoto:
            return @"Back right angle showing plate";
        case InsidePhoto:
            return @"Inside photo showing the entire back seat";
        case TrunkPhoto:
            return @"Open trunk, full view";
    }
}

- (NSString *)validationMessage {
    return @"Please upload the car photo required to continue.";
}

- (NSString *)confirmationMessage {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return @"Are you sure the Photo is clearly taken from the Front left angle side and shows your license plate?";
        case BackPhoto:
            return @"Are you sure the Photo is clearly taken from the Back right angle side and shows your license plate?";
        case InsidePhoto:
            return @"Are you sure the Photo is clearly taken from Inside the car showing the entire back seat?";
        case TrunkPhoto:
            return @"Are you sure the Photo is showing the Trunk open in full view?";
    }
}

- (UIImage *)carPhotoDefaultImage {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return [UIImage imageNamed:@"iconCarFront"];
        case BackPhoto:
            return [UIImage imageNamed:@"iconCarBack"];
        case InsidePhoto:
            return [UIImage imageNamed:@"iconCarInside"];
        case TrunkPhoto:
            return [UIImage imageNamed:@"iconCarTrunk"];
    }
}

- (DSScreen)screen {
    switch (self.carPhotoType) {
        case FrontPhoto: return DSScreenCarPhotoFront;
        case BackPhoto:  return DSScreenCarPhotoBack;
        case InsidePhoto:return DSScreenCarPhotoInside;
        case TrunkPhoto: return DSScreenCarPhotoTrunk;
    }
}

#pragma mark - Cache

- (void)saveImage:(UIImage *)image {
    NSString *photoType = [NSString stringWithPhotoType:self.carPhotoType];
    [super saveImage:image forKey:photoType];
}

- (UIImage *)cachedImage {
    NSString *photoType = [NSString stringWithPhotoType:self.carPhotoType];
    return [self.cache imageFromCacheForKey:photoType];
}

- (NSData *)cachedData {
    return [self.cachedImage compressToMaxSize:300000];
}

- (void)submitDocumentWithDriver:(NSNumber *)driverId car:(NSNumber *)carId andCompletion:(void (^)(NSError * _Nullable))completion {
    NSString *photoType = [NSString stringWithPhotoType:self.carPhotoType];
    NSParameterAssert(self.cachedImage != nil);
    NSParameterAssert(self.cachedData != nil);
    [RADriverAPI postPhotoForCarWithId:carId.stringValue photoType:photoType fileData:self.cachedData andCompletion:^(id responseObject, NSError *error) {
        if (!error) {
            self.isSubmitted = YES;
        }
        completion(error);
    }];
}

@end
