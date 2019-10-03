//
//  PromotionsViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PromotionsViewModel.h"

#import "ConfigurationManager.h"
#import "NSString+Utils.h"
#import "RARiderAPI.h"
#import "RASessionManager.h"

@implementation PromotionsViewModel

- (instancetype)initWithConfiguration:(ConfigGlobal *)config {
    if (self = [super init]) {
        _configGlobal = config;
    }
    return self;
}

- (NSString *)title {
    return [@"Promotions" localized];
}

- (NSString *)promoCodeTitle {
    return [NSString stringWithFormat:[@"If you have a %@ promo code, enter it and save on your ride." localized], [ConfigurationManager appName]];
}

- (BOOL)isReferFriendAvailable {
    ConfigReferRider *referFriend = self.configGlobal.referRider;
    return referFriend && referFriend.enabled;
}

- (CGFloat)referFriendHeightContainer {
    return self.isReferFriendAvailable ? 219.0 : 0;
}

- (BOOL)isCreditBalanceAvailable {
    ConfigPromoCredits *promoCredits = self.configGlobal.promoCredits;
    return promoCredits && promoCredits.showTotal;
}

- (BOOL)isCreditBalanceDetailAvailable {
    ConfigPromoCredits *promoCredits = self.configGlobal.promoCredits;
    RARiderDataModel *currentRider =  [[RASessionManager sharedManager] currentRider];
    return self.isCreditBalanceAvailable && promoCredits.showDetail && currentRider.remainingCredit.doubleValue > 0;
}

- (CGFloat)creditBalanceTopOffset {
    return self.isReferFriendAvailable ? 24.0 : 0;
}

- (CGFloat)creditBalanceHeightContainer {
    return self.isCreditBalanceAvailable ? 80.0 : 0;
}

- (NSString *)creditIconName {
    RARiderDataModel *currentRider =  [[RASessionManager sharedManager] currentRider];
    if (!currentRider.remainingCredit || currentRider.remainingCredit.doubleValue <= 0.0) {
        return @"credits-no-balance-icon";
    }
    return @"credits-available-icon";
}

- (NSString *)creditTitle {
    ConfigPromoCredits *promoCredits = self.configGlobal.promoCredits;
    return self.isCreditBalanceAvailable ? promoCredits.title : nil;
}

- (NSString *)creditTotal {
    RARiderDataModel *currentRider =  [[RASessionManager sharedManager] currentRider];
    if (currentRider.remainingCredit) {
        return [[NSString stringWithFormat:@"$%.2f", currentRider.remainingCredit.doubleValue] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
    return @"";
}

- (BOOL)isActivityIndicatorCreditBalanceLoading {
    RARiderDataModel *currentRider =  [[RASessionManager sharedManager] currentRider];
    return currentRider.remainingCredit ? NO : YES;
}

- (void)loadRemainingCredit {
    RARiderDataModel *currentRider =  [[RASessionManager sharedManager] currentRider];
    [RARiderAPI redemptionsRemainderForRiderWithId:currentRider.modelID.stringValue completion:^(id responseObject, NSError *error) {
        if (!error) {
            [RASessionManager sharedManager].currentRider.remainingCredit = responseObject;
        }
    }];
}

@end
