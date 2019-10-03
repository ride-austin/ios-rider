//
//  RACardDataModel.m
//  Ride
//
//  Created by Robert on 3/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//
#import "RACardDataModel.h"

@implementation RACardDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RACardDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"cardNumber": @"cardNumber",
             @"expMonth" : @"expirationMonth",
             @"expYear" : @"expirationYear",
             @"cardBrand": @"cardBrand",
             @"cardExpired": @"cardExpired",
             @"primary": @"primary"
             };
}

- (BOOL)isEqual:(id)object {
    if (object == self) {return YES;}
    return ([object isMemberOfClass:[RACardDataModel class]] && [((RACardDataModel*)object).modelID isEqualToNumber:self.modelID]);
}

@end
