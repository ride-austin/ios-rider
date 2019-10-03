//
//  RAEventParameters.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAEventParameters.h"

@implementation RAEventParameters

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *JSONKeyPaths =
    @{
      @"surgeAreas" : @"surgeAreas"
      };
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:JSONKeyPaths];
}

+ (NSValueTransformer *)surgeAreasJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RASurgeAreaDataModel.class];
}

@end
