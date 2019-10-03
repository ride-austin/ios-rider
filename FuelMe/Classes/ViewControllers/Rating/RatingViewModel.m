//
//  RatingViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 10/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RatingViewModel.h"
#import "RAMacros.h"
#import "UnratedRideManager.h"

@interface RatingViewModel()

@property (nonatomic) UnratedRide *unrated;
@property (nonatomic) ConfigurationManager *configurationManager;

@end

@implementation RatingViewModel

#pragma mark - Init

- (instancetype)initWithRide:(UnratedRide *)unrated configuration:(ConfigurationManager *)configuration {
    if (self = [super init]) {
        self.unrated = unrated;
        self.configurationManager = configuration;
        self.selectedTipIndex = -1; //No control segment selected
    }
    return self;
}

#pragma mark - Readonly properties

- (NSURL *)driverPhotoURL {
    return self.unrated.ride.activeDriver.driver.photoURL;
}

- (NSString *)commentTitle {
    return [NSString stringWithFormat:@"What feedback would you give %@?", self.unrated.ride.activeDriver.driver.user.displayName];
}

- (NSString *)summaryDescription {
    ConfigRides *ridesConfig = self.configurationManager.global.ridesConfig;
    if (self.unrated.ride.freeCreditCharged.integerValue > 0) {
        return ridesConfig.rideSummaryDescriptionFreeCreditCharged;
    } else {
        return ridesConfig.rideSummaryDescription;
    }
}

- (NSString *)totalLabel {
    return self.zeroFareLabel ?: self.totalCost;
}

- (NSString *)totalCost {
    return [NSString stringWithFormat:@"$ %0.2f", self.unrated.ride.totalFare.doubleValue];
}

- (NSString *)zeroFareLabel {
    NSString *promoCarZeroFareLabel = self.unrated.ride.requestedCarType.zeroFareLabel;
    if ([promoCarZeroFareLabel isKindOfClass:NSString.class] && promoCarZeroFareLabel.length > 0) {
        return promoCarZeroFareLabel;
    }
    return nil;
}

- (NSInteger)maxCommentLength {
    return 1200;
}

- (RAPaymentProvider *)paymentProvider {
    return self.unrated.paymentProvider;
}

- (CGFloat)limitValueToAskConfirmation {
    return 50.0;
}

- (NSString *)tipConfirmationMessage {
    return [NSString stringWithFormat:@"Please confirm that you are tipping $%.2f", self.unrated.userTip.floatValue];
}

#pragma mark - Setters

- (void)setRating:(CGFloat)rating {
    _rating = rating;
    self.unrated.userRating = [NSString stringWithFormat:@"%f", rating];
    if (self.delegate) {
        [self.delegate ratingViewModelDidUpdate];
    }
}

- (void)setSelectedTipIndex:(NSInteger)selectedTipIndex {
    _selectedTipIndex = selectedTipIndex;
    self.unrated.userTip = [self tipForIndex:selectedTipIndex];
    if (self.delegate) {
        [self.delegate ratingViewModelDidUpdate];
    }
}

#pragma mark - Methods

- (BOOL)shouldShowTip {
    return self.unrated.shouldShowTip;
}

- (BOOL)shouldShowPaymentProvider {
    return self.unrated.shouldShowPaymentProvider;
}

- (BOOL)canEnableSubmitButton {
    return self.rating > 0 && self.selectedTipIndex != UISegmentedControlNoSegment;
}

- (NSString *)tipForIndex:(NSInteger)index {
    switch (index) {
        case 1:  return @"1";
        case 2:  return @"2";
        case 3:  return @"5";
        default: return nil;
    }
}

- (void)setPaymentMethod {
    if (!self.paymentProvider) {
        self.unrated.paymentMethod = PaymentMethodUnspecified;
    } else if (self.paymentProvider && !self.paymentProvider.switchHidden && !self.isPaymentProviderSwitchOn) {
        self.unrated.paymentMethod = PaymentMethodPrimaryCreditCard;
    } else {
        self.unrated.paymentMethod = PaymentMethodBevoBucks;
    }
}

- (NSInteger)maxTipLength {
    return self.maxTipValue.stringValue.length;
}

- (NSNumber *)maxTipValue {
    return [UnratedRideManager shared].tipLimit;
}

- (NSString *)temporaryRideID {
    return self.unrated.rideID;
}

#pragma mark - Setters

- (void)setUserTip:(NSString *)userTip {
    self.unrated.userTip = userTip;
    if (userTip.integerValue > self.limitValueToAskConfirmation) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:self.tipConfirmationMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.delegate ratingViewModelDidClearTextField];
            self.unrated.userTip = nil;
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil]];
        [self.delegate presentViewController:alert animated:YES completion:nil];
    }
}
- (void)setComment:(NSString *)comment {
    if ([comment isKindOfClass:NSString.class] && comment.length > 0) {
        self.unrated.userComment = comment;
    } else {
        self.unrated.userComment = nil;
    }
}

- (void)submitRatingWithCompletion:(void (^)(float userRating))completion {
    //
    //  accessibility riders are allowed to close rating screen without rating
    //  if he adds tip or comment, we send it as 5 rating.
    //  Just a workaround because the stars slider really doesn't work on my devices
    //
    UnratedRide *unrated = self.unrated;
    if (UIAccessibilityIsVoiceOverRunning()) {
        if (unrated.userRating.doubleValue == 0) {
            if (unrated.userTip > 0 || IS_EMPTY(unrated.userComment) == NO) {
                unrated.userRating = @"5";
                [UnratedRideManager addRideToSubmit:unrated];
            }
        } else {
            [UnratedRideManager addRideToSubmit:unrated];
        }
        
    } else {
        [UnratedRideManager addRideToSubmit:unrated];
    }
    completion(unrated.userRating.floatValue);
}
@end
