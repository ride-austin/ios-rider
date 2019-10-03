//
//  RAPaymentHelper.m
//  Ride
//
//  Created by Roberto Abreu on 10/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPaymentHelper.h"
#import "RASessionManager.h"
#import <UIKit/UIKit.h>

@implementation RAPaymentHelper

+ (PaymentItem *)selectedPaymentMethod {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    PaymentMethod paymentMethod = rider.preferredPaymentMethod;
    switch (paymentMethod) {
        case PaymentMethodApplePay:
            return [PaymentItem paymentItemWithText:@"Apple Pay" textColor:nil andIconItem:[UIImage imageNamed:@"apple_pay"]];
        case PaymentMethodBevoBucks:
            return [PaymentItem paymentItemWithText:@"Bevo Pay" textColor:nil andIconItem:[UIImage imageNamed:@"bevoPay"]];
        case PaymentMethodPrimaryCreditCard:
        case PaymentMethodUnspecified:
            if (rider.primaryCard) {
                return [PaymentItem paymentItemWithCard:rider.primaryCard];
            } else {
                return [PaymentItem paymentItemWithText:@"Select Payment Method " textColor:nil andIconItem:nil];
            }
    }
}

@end
