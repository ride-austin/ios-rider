//
//  DSLicenseViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"

@interface DSLicenseViewModel : DSViewModel

- (NSString * _Nonnull)headerText;
- (NSString * _Nonnull)validationMessage;
- (NSString * _Nonnull)validationDateMessage;
- (void)saveImage:(UIImage * _Nullable)image;
- (UIImage * _Nullable)cachedImage;

@end
