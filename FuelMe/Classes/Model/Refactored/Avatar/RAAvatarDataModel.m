//
//  RAAvatarDataModel.m
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAAvatarDataModel.h"

static NSString *const kDataModelAvatarRider  = @"RIDER";
static NSString *const kDataModelAvatarDriver = @"DRIVER";
static NSString *const kDataModelAvatarAdmin  = @"ADMIN";

@implementation RAAvatarDataModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RAAvatarDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
              @"active": @"active",
              @"typeString": @"type"
            };
}

- (RAAvatarType)type {
    if ([kDataModelAvatarDriver isEqualToString:self.typeString]) {
        return RAAvatarDriver;
    } else if ([kDataModelAvatarRider isEqualToString:self.typeString]) {
        return RAAvatarRider;
    } else if ([kDataModelAvatarAdmin isEqualToString:self.typeString]) {
        return RAAvatarAdmin;
    } else {
        return RAAvatarUnknown;
    }
}

@end
