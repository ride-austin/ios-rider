//
//  RAPaymentHelper.h
//  Ride
//
//  Created by Roberto Abreu on 10/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentItem.h"

@interface RAPaymentHelper : NSObject

+ (PaymentItem*)selectedPaymentMethod;

@end
