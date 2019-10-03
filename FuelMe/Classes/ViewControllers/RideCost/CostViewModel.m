//
//  CostViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CostViewModel.h"

@implementation CostViewModel

- (instancetype)initWithTitle:(NSString *)title costType:(CostType)type number:(NSNumber *)number orValue:(CGFloat)value withDescription:(NSString *)description {
    self = [super init];
    if (self) {
        _costType    = type;
        _title       = title;
        _value       = value;
        _valueNumber = number;
        _feeDescription = description ? (description.length > 0 ? description : nil) : nil;
    }
    return self;
}

+ (instancetype)modelWithTitle:(NSString *)title andAmount:(CGFloat)amount {
    return [[CostViewModel alloc] initWithTitle:title costType:CostTypeAmount number:nil orValue:amount withDescription:nil];
}

+ (instancetype)modelWithTitle:(NSString *)title andAmount:(CGFloat)amount withDescription:(NSString *)description {
    return [[CostViewModel alloc] initWithTitle:title costType:CostTypeAmount number:nil orValue:amount withDescription:description];
}

+ (instancetype)modelWithTitle:(NSString *)title andRate:(NSNumber *)rate {
    return [[CostViewModel alloc] initWithTitle:title costType:CostTypeRate number:rate orValue:rate.floatValue withDescription:nil];
}

+ (instancetype)modelWithTitle:(NSString *)title andRate:(NSNumber *)rate withDescription:(NSString *)description {
    return [[CostViewModel alloc] initWithTitle:title costType:CostTypeRate number:rate orValue:rate.floatValue withDescription:description];
}

+ (instancetype)modelWithFee:(RAFee *)fee {
    switch (fee.type) {
        case RAFeeTypeRate:
            return [CostViewModel modelWithTitle:fee.title
                                         andRate:fee.value
                                 withDescription:fee.feeDescription];
            
        case RAFeeTypeAmount:
            return [CostViewModel modelWithTitle:fee.title
                                       andAmount:fee.value.floatValue
                                 withDescription:fee.feeDescription];
    }
}

- (NSString *)displayValue {
    switch (self.costType) {
        case CostTypeRate:  return [NSString stringWithFormat:@"%@%%", self.valueNumber];
        case CostTypeAmount:return [NSString stringWithFormat:@"$ %0.2f", self.value];
    }
}

@end
