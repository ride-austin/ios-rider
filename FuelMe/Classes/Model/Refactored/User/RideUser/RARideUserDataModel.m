//
//  RARideUserDataModel.m
//  RideAustin
//
//  Created by Kitos on 2/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RARideUserDataModel.h"

@implementation RARideUserDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RARideUserDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"rating": @"rating"
            };
}

+ (NSValueTransformer *)ratingJSONTransformer {
    return [self stringToNumberTransformer];
}

- (NSString *)displayRating {
    NSNumberFormatter *ratingFormatter = [NSNumberFormatter new];
    [ratingFormatter setMinimumFractionDigits:2];
    [ratingFormatter setMaximumFractionDigits:2];
    [ratingFormatter setRoundingMode:NSNumberFormatterRoundDown];
    return [ratingFormatter stringFromNumber:self.rating];
}

@end
