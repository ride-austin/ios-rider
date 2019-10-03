//
//  RAPromoCode.m
//  Ride
//
//  Created by Kitos on 7/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAPromoCode.h"

@implementation RAPromoCode

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"codeLiteral" : @"codeLiteral",
              @"codeValue"   : @"codeValue",
              @"maxRedemption" : @"maximunRedemption",
              @"currentRedemption" : @"currentRedemption",
              @"detailText" : @"detailText",
              @"emailBody" : @"emailBody",
              @"smsBody" : @"smsBody",
              @"remainingCredit" : @"remainingCredit"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        _totalRedemption = [NSNumber numberWithInt:[_codeValue intValue] * [_maxRedemption intValue]];
    }
    return self;
}

@end
