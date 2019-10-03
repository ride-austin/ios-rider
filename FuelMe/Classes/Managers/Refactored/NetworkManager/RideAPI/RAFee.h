//
//  RAFee.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/23/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger, RAFeeType) {
    RAFeeTypeAmount = 0,
    RAFeeTypeRate   = 1
};

@interface RAFee : RABaseDataModel

@property (nonatomic, readonly) NSString * _Nonnull title;
@property (nonatomic, readonly) NSNumber * _Nonnull value;
@property (nonatomic, readonly) NSString * _Nullable feeDescription;

- (RAFeeType)type;

@end
