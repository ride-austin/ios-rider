//
//  ApplePayHelper.h
//  Ride
//
//  Created by Roberto Abreu on 5/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarCategoryDataModel.h"

extern NSString *const kTitleApplePay;
extern NSString *const kTitleSetupApplePay;
extern NSString *const kAlertTitleSetupApplePay;
extern NSString *const kAlertMessageSetupApplePay;
extern NSString *const kApplePaymentInvalidDomainError;

typedef void(^ApplePayTokenBlock)(NSString *token, NSError *error);

@interface ApplePayHelper : NSObject

+ (instancetype)sharedInstance;
+ (BOOL)canMakePayment;
+ (BOOL)hasApplePaySetup;
+ (void)openSettingsApplePay;
+ (UIButton*)applePayButton;
+ (UIButton*)applePaySetupButton;

- (void)showApplePayAuthorizationWithCategory:(RACarCategoryDataModel *)carCategory completion:(ApplePayTokenBlock)completion;

@end
