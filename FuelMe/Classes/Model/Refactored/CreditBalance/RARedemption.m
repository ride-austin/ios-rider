//
//  RACreditBalance.m
//  Ride
//
//  Created by Roberto Abreu on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARedemption.h"

@implementation RARedemption

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"codeLiteral"    : @"codeLiteral",
              @"maximumUses"    : @"maximumUses",
              @"remainingValue" : @"remainingValue",
              @"timesUsed"      : @"timesUsed",
              @"expiresOn"      : @"expiresOn"
            };
}

+ (NSValueTransformer *)expiresOnJSONTransformer {
    return [self numberToDateTransformer];
}

@end
