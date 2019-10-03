//
//  RACardDataModel.h
//  Ride
//
//  Created by Robert on 3/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RACardDataModel : RABaseDataModel

@property (nonatomic, strong, nonnull) NSString *cardNumber;
@property (nonatomic, strong, nonnull) NSString *cardBrand;
@property (nonatomic, strong, nonnull) NSNumber *cardExpired;
@property (nonatomic, strong, nonnull) NSNumber *primary;
@property (nonatomic, strong, nullable) NSString *expMonth;
@property (nonatomic, strong, nullable) NSString *expYear;

@end
