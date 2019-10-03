//
//  ConfigUT.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigUT.h"

@implementation ConfigUT

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"payWithBevoBucks"   : @"payWithBevoBucks"
            };
}

+ (NSValueTransformer *)payWithBevoBucksJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigUTPayWithBevoBucks class]];
}

@end
