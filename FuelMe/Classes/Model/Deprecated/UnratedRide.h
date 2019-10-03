//
//  UnratedRide.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAPaymentProvider.h"
#import "RARideDataModel.h"
#import "RideConstants.h"

@interface UnratedRide : MTLModel

@property (nonatomic, readonly) RARideDataModel *ride;

//  User Input cached
@property (nonatomic) NSString *userRating;
@property (nonatomic) NSString *userTip;
@property (nonatomic) NSString *userComment;
@property (nonatomic) PaymentMethod paymentMethod;
@property (nonatomic, readonly) RAPaymentProvider *paymentProvider;

- (instancetype)initWithRide:(RARideDataModel*)ride andPaymentMethod:(PaymentMethod)paymentMethod;
- (BOOL)shouldShowTip;

// for sending
- (NSString *)rideID;
- (NSString *)validatedTip;
- (BOOL)shouldShowPaymentProvider;
- (NSString *)paymentMethodRequestParameter;

@end

@interface UnratedRide (MTLJSONSerializing) <MTLJSONSerializing>

@end
