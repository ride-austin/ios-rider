//
//  RADriverDataModel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RADriverDataModel.h"

@implementation RADriverDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RADriverDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"cars" : @"cars",
             @"user" : @"user",
             @"isDeaf" : @"isDeaf"
            };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)carsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RACarDataModel.class];
}

@end
