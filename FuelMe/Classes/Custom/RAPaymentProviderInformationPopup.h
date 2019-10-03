//
//  RAPaymentProviderInformationPopup.h
//  Ride
//
//  Created by Roberto Abreu on 8/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPaymentProviderInformationPopup : UIView

+ (instancetype)paymentProviderWithImage:(UIImage*)image name:(NSString*)name detail:(NSString*)detail;
+ (instancetype)paymentProviderWithPhotoURL:(NSURL*)url name:(NSString*)name detail:(NSString*)detail;

- (void)show;
- (void)dismiss;

@end
