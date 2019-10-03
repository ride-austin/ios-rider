//
//  DSInspectionStickerViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"

@interface DSInspectionStickerViewModel : DSViewModel

@property (nonatomic, nullable) NSDate *expirationDate;

#pragma mark - Text
- (NSString * _Nonnull)headerText;
- (NSString * _Nonnull)title;
- (NSString * _Nonnull)subTitle;
- (NSString * _Nonnull)validationMessage;
- (NSString * _Nonnull)validationDateMessage;
- (void)saveImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedImage;
- (void)submitDocumentWithDriver:(NSNumber * _Nonnull)driverId car:(NSNumber * _Nonnull)carId city:(NSNumber * _Nonnull)cityId withCompletion:(void (^ _Nonnull)(NSError * _Nullable error))completion;

@end
