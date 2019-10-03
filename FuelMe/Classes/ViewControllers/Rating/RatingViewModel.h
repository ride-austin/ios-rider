//
//  RatingViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 10/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigurationManager.h"
#import "UnratedRide.h"

@protocol RatingViewModelDelegate

- (void)ratingViewModelDidUpdate;
- (void)ratingViewModelDidClearTextField;

@end

@interface RatingViewModel : NSObject

@property (weak, nonatomic) UIViewController<RatingViewModelDelegate> *delegate;
@property (nonatomic, readonly) NSURL *driverPhotoURL;
@property (nonatomic, readonly) NSString *commentTitle;
@property (nonatomic, readonly) NSString *summaryDescription;
@property (nonatomic, readonly) NSString *totalLabel;
@property (nonatomic, readonly) NSInteger maxCommentLength;
@property (nonatomic, readonly) RAPaymentProvider *paymentProvider;
@property (nonatomic, readonly) CGFloat limitValueToAskConfirmation;
@property (nonatomic, readonly) NSString *tipConfirmationMessage;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) NSInteger selectedTipIndex;
@property (nonatomic, assign) BOOL isPaymentProviderSwitchOn;
@property (nonatomic, assign) BOOL isFromDeeplink;


- (instancetype)initWithRide:(UnratedRide*)unrated configuration:(ConfigurationManager*)configuration;
- (BOOL)shouldShowTip;
- (BOOL)shouldShowPaymentProvider;
- (BOOL)canEnableSubmitButton;
- (NSString *)tipForIndex:(NSInteger)index;
- (void)setPaymentMethod;
- (NSInteger)maxTipLength;
- (NSNumber *)maxTipValue;

- (NSString *)temporaryRideID;

#pragma mark - Setters
- (void)setUserTip:(NSString *)userTip;
- (void)setComment:(NSString *)comment;
- (void)submitRatingWithCompletion:(void (^)(float userRating))completion;
@end
