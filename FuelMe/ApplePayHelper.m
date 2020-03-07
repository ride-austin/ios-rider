//
//  ApplePayHelper.m
//  Ride
//
//  Created by Roberto Abreu on 5/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ApplePayHelper.h"

#import <PassKit/PassKit.h>

#import "ConfigurationManager.h"
#import "SystemVersionCompare.h"

#import <Stripe/Stripe.h>

NSString *const kTitleApplePay = @"Apple Pay";
NSString *const kTitleSetupApplePay = @"Set up Apple Pay";
NSString *const kAlertTitleSetupApplePay = @"Review Payment method";
NSString *const kAlertMessageSetupApplePay = @"Please set up Apple Pay to request a ride";
NSString *const kApplePaymentInvalidDomainError = @"com.rideaustin.apple.pay.invalid";

@interface ApplePayHelper() <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic) NSString *lastApplePayToken;
@property (nonatomic, copy) ApplePayTokenBlock tokenCompletion;

@end

@implementation ApplePayHelper

+ (instancetype)sharedInstance {
    static ApplePayHelper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ApplePayHelper alloc] init];
    });
    return sharedInstance;
}

+ (BOOL)canMakePayment {
    return [PKPaymentAuthorizationViewController class] && [PKPaymentAuthorizationViewController canMakePayments];
}

+ (BOOL)hasApplePaySetup {
    return [PKPaymentAuthorizationViewController class] && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[self supportedPKPaymentNetworks]];
}

+ (NSArray<NSString *> *)supportedPKPaymentNetworks {
    NSArray *supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
    if ((&PKPaymentNetworkDiscover) != NULL) {
        supportedNetworks = [supportedNetworks arrayByAddingObject:PKPaymentNetworkDiscover];
    }
    return supportedNetworks;
}

+ (void)openSettingsApplePay {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.3") && [PKPassLibrary isPassLibraryAvailable]) {
        PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
        [passLibrary openPaymentSetup];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)showApplePayAuthorizationWithCategory:(RACarCategoryDataModel *)carCategory completion:(ApplePayTokenBlock)completion {
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.com.rideaustin.public" country:@"US" currency:@"USD"];
    
    NSDecimalNumber *baseFareAmount = [[NSDecimalNumber alloc] initWithFloat:[[carCategory baseFareApplyingSurge] floatValue]];
    PKPaymentSummaryItem *baseFareSummaryItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Base Fare" amount:baseFareAmount];
    
    PKPaymentSummaryItem *rideCostSummaryItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Time & Distance (TBD)" amount:[[NSDecimalNumber alloc] initWithFloat:0.0]];
    
    PKPaymentSummaryItem *rideTotalSummaryItem;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        rideTotalSummaryItem = [PKPaymentSummaryItem summaryItemWithLabel:[ConfigurationManager appName] amount:baseFareAmount type:PKPaymentSummaryItemTypePending];
    } else {
        rideTotalSummaryItem = [PKPaymentSummaryItem summaryItemWithLabel:[NSString stringWithFormat:@"%@ (TOTAL TBD)",[ConfigurationManager appName]] amount:baseFareAmount];
    }
    
    [paymentRequest setPaymentSummaryItems:@[baseFareSummaryItem,rideCostSummaryItem,rideTotalSummaryItem]];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
        self.lastApplePayToken = nil;
        self.tokenCompletion = completion;
        PKPaymentAuthorizationViewController *paymentAuthorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        paymentAuthorizationViewController.delegate = self;
        [rootController presentViewController:paymentAuthorizationViewController animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:kAlertTitleSetupApplePay message:kAlertMessageSetupApplePay preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Change Payment Method" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSError *error = [NSError errorWithDomain:kApplePaymentInvalidDomainError code:-1 userInfo:nil];
            completion(nil, error);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:kTitleSetupApplePay style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ApplePayHelper openSettingsApplePay];
        }]];
        [rootController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - ApplePay Authorization Delegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    __weak ApplePayHelper *weakSelf = self;
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
        } else {
            weakSelf.lastApplePayToken = token.tokenId;
            completion(PKPaymentAuthorizationStatusSuccess);
        }
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        self.tokenCompletion(self.lastApplePayToken, nil);
        self.tokenCompletion = NULL;
    }];
}

@end
