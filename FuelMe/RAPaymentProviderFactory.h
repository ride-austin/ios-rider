//
//  RAPaymentProviderFactory.h
//  Ride
//
//  Created by Roberto Abreu on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAPaymentProvider.h"
#import "RideConstants.h"

@interface RAPaymentProviderFactory : NSObject

+ (RAPaymentProvider*)paymentProviderWithName:(NSString*)paymentProviderName;
+ (RAPaymentProvider*)paymentProviderWithPreferredPaymentMethod:(PaymentMethod)paymentMethod;

@end
