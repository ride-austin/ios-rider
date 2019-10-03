//
//  DSCarPhotoViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigRegistration.h"
#import "DSConstants.h"
#import "DSViewModel.h"
#import "RideConstants.h"

@interface DSCarPhotoViewModel : DSViewModel

@property (nonatomic, readonly) CarPhotoType carPhotoType;
@property (nonatomic) BOOL didConfirm;

- (instancetype _Nonnull)initWithType:(CarPhotoType)carPhotoType config:(ConfigRegistration * _Nonnull)config andCache:(SDImageCache * _Nonnull)cache;
- (NSString * _Nonnull)headerText;
- (NSString * _Nonnull)carPhotoDescription;
- (NSString * _Nonnull)validationMessage;
- (NSString * _Nonnull)confirmationMessage;
- (UIImage * _Nonnull)carPhotoDefaultImage;
- (DSScreen)screen;
#pragma mark - Cache
- (void)saveImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedImage;

- (void)submitDocumentWithDriver:(NSNumber * _Nonnull)driverId car:(NSNumber * _Nonnull)carId andCompletion:(void (^ _Nonnull)(NSError * _Nullable error))completion;
@end
