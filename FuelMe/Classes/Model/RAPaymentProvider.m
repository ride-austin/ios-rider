//
//  RAPaymentProvider.m
//  Ride
//
//  Created by Roberto Abreu on 8/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPaymentProvider.h"

@implementation RAPaymentProvider

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail switchHidden:(BOOL)switchHidden logoUrl:(NSURL *)logoUrl paymentDelay:(NSNumber *)paymentDelay {
    if (self = [super init]) {
        self.name = name;
        self.detail = detail;
        self.switchHidden = switchHidden;
        self.logoUrl = logoUrl;
        self.paymentDelay = paymentDelay;
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"name" : @"name",
              @"detail" : @"detail",
              @"switchHidden" : @"switchHidden",
              @"logoUrl" : @"logoUrl",
              @"paymentDelay" : @"paymentDelay"
            };
}

+ (NSValueTransformer *)logoUrlJSONTransformer {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

@end
