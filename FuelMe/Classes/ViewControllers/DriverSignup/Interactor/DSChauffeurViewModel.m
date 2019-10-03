//
//  DSChauffeurViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSChauffeurViewModel.h"
#import "RADriverAPI.h"
#import "UIImage+Ride.h"
#import "UIImage+Utils.h"

@implementation DSChauffeurViewModel

- (TNCScreenDetail *)tnc {
    return self.config.cityDetail.tnc;
}

#pragma mark - Text

- (NSString *)headerText {
    return self.tnc.headerText;
}

- (NSString *)headerTextBack {
    return self.tnc.title1Back;
}

- (NSString *)title1 {
    return self.tnc.title1;
}

- (NSString *)title1Back {
    return self.tnc.title1Back;
}

- (NSString *)subtitle1 {
    return self.tnc.text1;
}

- (NSString *)subtitle1Back {
    return self.tnc.text1Back;
}

- (NSString *)title2 {
    return self.tnc.title2;
}

- (NSAttributedString *)subtitle2 {
    NSString *stringHTML = [NSString stringWithFormat:@"<span style=\"font-family: Montserrat-Light; font-size: 14; color:#3C4350\">%@</span>",self.tnc.text2];
    NSData *dataHTML = [stringHTML dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:dataHTML
                                                                            options:options
                                                                 documentAttributes:nil
                                                                              error:nil];
    return attributedString;
}

- (NSString *)validationMessage {
    return [NSString stringWithFormat:@"Please upload %@ photo to continue", self.tnc.title1];
}

- (NSString *)validationMessageBack {
    return [NSString stringWithFormat:@"Please upload %@ photo to continue", self.tnc.title1Back];
}

- (NSString *)confirmationMessage {
    return [NSString stringWithFormat:@"Are you sure %@ is clearly shown in the photo?", self.tnc.title1];
}

- (NSString *)confirmationMessageBack {
    return [NSString stringWithFormat:@"Are you sure %@ is clearly shown in the photo?", self.tnc.title1Back];
}

- (BOOL)needsBackPhoto {
    return self.tnc.needsBackPhoto;
}

#pragma mark - Actions

- (void)saveFrontImage:(UIImage *)image {
    [super saveImage:image forKey:kTNCImageFront];
}

- (UIImage *)cachedFrontImage {
    return [self.cache imageFromCacheForKey:kTNCImageFront];
}

- (NSData *)cachedFrontData {
    return [self.cachedFrontImage compressToMaxSize:300000];
}

- (void)saveBackImage:(UIImage *)image {
    if (image) {
        [self.cache storeImage:image forKey:kTNCImageBack completion:^{
            
        }];
    } else {
        [self.cache removeImageForKey:kTNCImageBack withCompletion:^{
            
        }];
    }
}

- (UIImage *)cachedBackImage {
    return [self.cache imageFromCacheForKey:kTNCImageBack];
}

- (NSData *)cachedBackData {
    return [self.cachedBackImage compressToMaxSize:300000];
}

- (void)submitDocumentWithDriver:(NSNumber *)driverId city:(NSNumber *)cityId withCompletion:(void (^)(NSError * _Nullable))completion {
    NSDateFormatter *dfServer = [[NSDateFormatter alloc] init];
    dfServer.dateFormat = @"yyyy-MM-dd";
    
    UIImage *finalImage = self.cachedFrontImage;
    if (self.cachedFrontImage && self.cachedBackImage) {
        finalImage = [finalImage combineWithImage:self.cachedBackImage];
    }
    
    NSData *imageData = [finalImage compressToMaxSize:600000];
    NSParameterAssert(imageData);
    [RADriverAPI postChauffeurLicenseWithDriverId:driverId.stringValue cityId:cityId validityDate:[dfServer stringFromDate:self.expirationDate] fileData:imageData completion:^(NSError * _Nullable error) {
        if (!error) {
            self.isSubmitted = YES;
        }
        completion(error);
    }];
}

@end
