//
//  UnpaidBalanceViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentItem.h"

@class RAUnpaidBalance;
@class ConfigUnpaidBalance;

@interface UnpaidBalanceViewModel : NSObject

@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) PaymentItem *selectedPaymentMethod;

+ (instancetype)modelWithBalance:(RAUnpaidBalance *)unpaidBalance
                   paymentMethod:(PaymentItem *)paymentItem
                          config:(ConfigUnpaidBalance *)config;

- (NSString *)displayAmount;
- (NSString *)amount;
- (NSString *)headerText;
- (NSURL*)bevoBucksUrl;
- (NSString*)rideId;

@end
