//
//  UnpaidBalanceViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UnpaidBalanceViewModel.h"

#import "ConfigurationManager.h"
#import "RAUnpaidBalance.h"

@interface UnpaidBalanceViewModel()

@property (nonatomic, readonly) RAUnpaidBalance *unpaidBalance;

@end

@implementation UnpaidBalanceViewModel

+ (instancetype)modelWithBalance:(RAUnpaidBalance *)unpaidBalance paymentMethod:(PaymentItem *)paymentItem config:(ConfigUnpaidBalance *)config {
    return [[self alloc] initWithBalance:unpaidBalance paymentMethod:paymentItem config:config];
}

- (instancetype)initWithBalance:(RAUnpaidBalance *)unpaidBalance paymentMethod:(PaymentItem *)paymentItem config:(ConfigUnpaidBalance *)config {
    if (self = [super init]) {
        _unpaidBalance = unpaidBalance;
        _selectedPaymentMethod = paymentItem;
        _title    = config.title;
        _subtitle = config.subtitle;
    }
    return self;
}

- (NSString *)displayAmount {
    return self.unpaidBalance.displayAmount;
}

- (NSString *)amount {
    return self.unpaidBalance.amount;
}

- (NSString *)headerText {
    return @"Payment Method";
}

- (NSURL *)bevoBucksUrl {
    return self.unpaidBalance.bevoBucksUrl;
}

- (NSString *)rideId {
    return self.unpaidBalance.rideId.stringValue;
}

@end
