//
//  DSChauffeurViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"

@interface DSChauffeurViewModel : DSViewModel
@property (nonatomic, nullable) NSDate *expirationDate;
@property (nonatomic) BOOL didConfirmFront;
@property (nonatomic) BOOL didConfirmBack;

#pragma mark - Text
- (NSString *_Nonnull)headerText;
- (NSString *_Nonnull)headerTextBack;
- (NSString *_Nonnull)title1;
- (NSString *_Nonnull)title1Back;
- (NSString *_Nonnull)subtitle1;
- (NSString *_Nonnull)subtitle1Back;
- (NSString *_Nonnull)title2;
- (NSAttributedString *_Nonnull)subtitle2;
- (NSString *_Nonnull)validationMessage;
- (NSString *_Nonnull)validationMessageBack;
- (NSString *_Nonnull)confirmationMessage;
- (NSString *_Nonnull)confirmationMessageBack;

- (BOOL)needsBackPhoto;
#pragma mark - Actions
- (void)saveFrontImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedFrontImage;

- (void)saveBackImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedBackImage;

- (void)submitDocumentWithDriver:(NSNumber * _Nonnull)driverId city:(NSNumber * _Nonnull)cityId withCompletion:(void(^ _Nonnull)(NSError * _Nullable error))completion;
@end
