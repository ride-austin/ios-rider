//
//  DSDriverPhotoViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"

@interface DSDriverPhotoViewModel : DSViewModel

@property (nonatomic) BOOL didConfirm;

- (NSString *_Nonnull)headerText;
- (NSString *_Nonnull)confirmationDescription;
- (void)saveImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedImage;
- (void)submitDocumentWithDriver:(NSNumber * _Nonnull)driverId withCompletion:(void(^_Nonnull)(NSError *_Nullable error))completion;

@end
