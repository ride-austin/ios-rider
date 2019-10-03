//
//  AddPaymentViewController.h
//  Ride
//
//  Created by Tyson Bunch on 5/18/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

#import <Stripe/Stripe.h>

@protocol PaymentProtocol <NSObject>

- (void)didAddPaymentMethod;

@end

@interface AddPaymentViewController : BaseViewController

@property (nonatomic, weak) id<PaymentProtocol> delegate;
@property (nonatomic, strong) IBOutlet STPPaymentCardTextField* stripeView;

@end
