//
//  RAFee.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/23/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAFee.h"

@interface RAFee()

@property (nonatomic) NSString *valueType;

@end

@implementation RAFee

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title" : @"title",
             @"value" : @"value",
             @"valueType" : @"valueType",
             @"feeDescription" : @"description"
            };
}

- (RAFeeType)type {
    if ([self.valueType isEqualToString:@"amount"]) {
        return RAFeeTypeAmount;
    } else if ([self.valueType isEqualToString:@"rate"]) {
        return RAFeeTypeRate;
    }
    return RAFeeTypeAmount;
}

/**
 *  shouldn't create city without title and value
 */
- (BOOL)validate:(NSError *__autoreleasing *)error {
    return [super validate:error] && self.title != nil && self.value != nil;
}

@end
