//
//  RACarDatamodel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RACarDataModel.h"

@interface RACarDataModel ()

@end

@implementation RACarDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RACarDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"licensePlate": @"license",
             @"make": @"make",
             @"model": @"model",
             @"year": @"year",
             @"color": @"color",
             @"photoURL": @"photoUrl",
             @"carCategories": @"carCategories",
            };
}

@end
