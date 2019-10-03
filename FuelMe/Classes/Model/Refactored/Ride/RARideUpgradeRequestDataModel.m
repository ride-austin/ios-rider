//
//  RARideUpgradeRequestDataModel.m
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARideUpgradeRequestDataModel.h"

@implementation RARideUpgradeRequestDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RARideUpgradeRequestDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"upgradeStatus": @"status",
             @"source": @"source",
             @"target" : @"target",
             @"surgeFactor" : @"surgeFactor",
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)upgradeStatusJSONTransformer {
    NSDictionary *statuses = @{
                               @"REQUESTED": @(RAURSRequested),
                               @"EXPIRED": @(RAURSExpired),
                               @"ACCEPTED": @(RAURSAccepted),
                               @"DECLINED": @(RAURSDeclined),
                               @"CANCELLED": @(RAURSCancelled)
                               };
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        *success = YES;
        if ([value isKindOfClass:[NSString class]]) {
            return statuses[(NSString*)value] ?: @(RAURSUnknown);
        }
        else {
            return @(RAURSUnknown);
        }
    }];    
}

@end
