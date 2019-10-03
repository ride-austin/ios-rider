//
//  RAPaymentField.h
//  Ride
//
//  Created by Roberto Abreu on 3/8/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PaymentItem.h"

typedef NS_ENUM(NSUInteger, RAPaymentFieldType){
    RAPaymentNumberFieldType = 0,
    RAPaymentExpirationFieldType = 1,
    RAPaymentCVVFieldType = 2
};

@interface RAPaymentField : UIControl

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSInteger type;
#else
@property (nonatomic) RAPaymentFieldType type;
#endif

@property (nonatomic) PaymentItem *paymentItem;

- (NSString *)month;
- (NSString *)year;
- (BOOL)isValid;

@end
