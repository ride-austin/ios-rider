//
//  StripeTokenResponseMock.m
//  Ride
//
//  Created by Roberto Abreu on 5/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "StripeTokenResponseMock.h"

@implementation StripeTokenResponseMock

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSString *cvc = dict[@"card[cvc]"];
    NSNumber *expirationMoth = dict[@"card[exp_month]"];
    NSNumber *expirationYear = dict[@"card[exp_year]"];
    NSString *cardNumber = dict[@"card[number]"];
    NSRange lastFourDigitsRange = NSMakeRange([cardNumber length] - 4, 4);
    NSString *lastFour = [cardNumber substringWithRange:lastFourDigitsRange];
    return [self initWithCVC:cvc lastFour:lastFour expirationMoth:expirationMoth expirationYear:expirationYear];
}

- (instancetype)initWithCVC:(NSString *)cvc lastFour:(NSString *)lastFour expirationMoth:(NSNumber *)expMonth expirationYear:(NSNumber *)expYear {
    if (self = [super init]) {
        self.cvc = cvc;
        self.lastFour = lastFour;
        self.expirationMonth = expMonth;
        self.expirationYear = expYear;
    }
    return self;
}

- (NSString*)cardBrandByCVC {
    if ([self.cvc isEqualToString:@"111"]) {
        return @"visa";
    } else if ([self.cvc isEqualToString:@"112"]) {
        return @"mastercard";
    } else if ([self.cvc isEqualToString:@"3022"]) {
        return @"american_express";
    } else if ([self.cvc isEqualToString:@"113"]) {
        return @"discover";
    } else if ([self.cvc isEqualToString:@"114"]) {
        return @"diners_club";
    } else if ([self.cvc isEqualToString:@"115"]) {
        return @"jcb";
    }
    
    return @"Card not supported";
}

- (NSData *)dataJSON {
    NSAssert(self.cardBrandByCVC , @"nil self.cardBrandByCVC");
    NSAssert(self.expirationMonth, @"nil self.expirationMonth");
    NSAssert(self.expirationYear , @"nil self.expirationYear");
    NSAssert(self.lastFour       , @"nil self.lastFound");
    NSDictionary *dictObject = @{
                                 @"card@" : @{
                                                @"address_city" : [NSNull null],
                                                @"address_country" : [NSNull null],
                                                @"address_line1" : [NSNull null],
                                                @"address_line1_check" : [NSNull null],
                                                @"address_line2" : [NSNull null],
                                                @"address_state" : [NSNull null],
                                                @"address_zip" : [NSNull null],
                                                @"address_zip_check" : [NSNull null],
                                                @"brand" : [self cardBrandByCVC],
                                                @"country" : @"US",
                                                @"cvc_check" : @"unchecked",
                                                @"dynamic_last4" : [NSNull null],
                                                @"exp_month" : self.expirationMonth,
                                                @"exp_year" : self.expirationYear,
                                                @"funding" : @"unknown",
                                                @"id" : @"card_1AIInQF1zTsipGiNOsEOwdGb",
                                                @"last4" : self.lastFour,
                                                @"metadata" : @{},
                                                @"name" : [NSNull null],
                                                @"object" : @"card",
                                                @"tokenization_method" : [NSNull null]
                                        },
                                 @"client_ip" : @"148.0.43.204",
                                 @"created" : @1494514900,
                                 @"id" : @"token_dummy",
                                 @"livemode" : @0,
                                 @"object" : @"token",
                                 @"type" : @"card",
                                 @"used" : @0
        };
    return [NSJSONSerialization dataWithJSONObject:dictObject options:NSJSONWritingPrettyPrinted error:nil];
}

@end
