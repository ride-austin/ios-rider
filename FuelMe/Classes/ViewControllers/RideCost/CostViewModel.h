//
//  CostViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAFee.h"

typedef NS_ENUM(NSUInteger, CostType) {
    CostTypeAmount,
    CostTypeRate
};

@interface CostViewModel : NSObject

@property (nonatomic, readonly) CostType costType;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSNumber *valueNumber;
@property (nonatomic, readonly) CGFloat value;
/**
 *  @returns nil when feeDescription is invalid
 */
@property (nonatomic, readonly) NSString *feeDescription;

+ (instancetype)modelWithTitle:(NSString *)title andAmount:(CGFloat)amount;
+ (instancetype)modelWithTitle:(NSString *)title andRate:(NSNumber *)rate;
+ (instancetype)modelWithFee:(RAFee *)fee;
- (NSString *)displayValue;

@end
