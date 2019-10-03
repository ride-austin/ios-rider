//
//  DSInspectionStickerViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSInspectionStickerViewModel.h"

#import "RADriverAPI.h"
#import "UIImage+Ride.h"

@implementation DSInspectionStickerViewModel

- (RAInspectionStickerDetail *)detail {
    return self.config.cityDetail.inspectionSticker;
}

#pragma mark - Text

- (NSString *)headerText {
    return self.detail.navBarTitle;
}

- (NSString *)title {
    return self.detail.title;
}

- (NSString *)subTitle {
    return self.detail.content;
}

- (NSString *)validationMessage {
    return [NSString stringWithFormat:@"Please upload %@ photo to continue", self.detail.navBarTitle];
}

- (NSString *)validationDateMessage {
    return @"Please, select a valid expiration date";
}

#pragma mark -

- (void)saveImage:(UIImage *)image {
    [super saveImage:image forKey:kInspectionSticker];
}

- (UIImage *)cachedImage {
    return [self.cache imageFromCacheForKey:kInspectionSticker];
}

- (NSData *)cachedData {
    return [self.cachedImage compressToMaxSize:700000];
}

- (void)submitDocumentWithDriver:(NSNumber *)driverId car:(NSNumber *)carId city:(NSNumber *)cityId withCompletion:(void (^)(NSError * _Nullable))completion {
    NSDateFormatter *dfServer = [[NSDateFormatter alloc] init];
    dfServer.dateFormat = @"yyyy-MM-dd";
    
    [RADriverAPI postInspectionStickerDocumentWithDriverId:driverId.stringValue carId:carId.stringValue validityDate:[dfServer stringFromDate:self.expirationDate] cityId:cityId fileData:self.cachedData completion:^(NSError * _Nullable error) {
        if (!error) {
            self.isSubmitted = YES;
        }
        completion(error);
    }];
}

@end
