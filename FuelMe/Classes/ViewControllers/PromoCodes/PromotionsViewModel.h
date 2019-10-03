//
//  PromotionsViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigGlobal.h"

@interface PromotionsViewModel : NSObject

@property (nonatomic) ConfigGlobal *configGlobal;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *promoCodeTitle;
@property (nonatomic, readonly) BOOL isReferFriendAvailable;
@property (nonatomic, readonly) CGFloat referFriendHeightContainer;
@property (nonatomic, readonly) BOOL isCreditBalanceAvailable;
@property (nonatomic, readonly) BOOL isCreditBalanceDetailAvailable;
@property (nonatomic, readonly) CGFloat creditBalanceTopOffset;
@property (nonatomic, readonly) CGFloat creditBalanceHeightContainer;
@property (nonatomic, readonly) NSString *creditIconName;
@property (nonatomic, readonly) NSString *creditTitle;
@property (nonatomic, readonly) NSString *creditTotal;
@property (nonatomic, readonly) BOOL isActivityIndicatorCreditBalanceLoading;

- (instancetype)initWithConfiguration:(ConfigGlobal*)config;
- (void)loadRemainingCredit;

@end
