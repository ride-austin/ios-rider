//
//  NSString+PhoneUtils.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "NSString+PhoneUtils.h"

#import <MRCountryPicker/MRCountryPicker-Swift.h>

@implementation NSString (PhoneUtils)

- (NSString*)clearedPhoneNumber {
    NSString *phone = self;
    
    NSError *error = nil;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[()\\-\\s]" options:NSRegularExpressionCaseInsensitive error:&error];
    phone = [regExp stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, phone.length) withTemplate:@""];

    NSRange zerosRange = [phone rangeOfString:@"00"];

    if (zerosRange.location == 0) {
        phone = [phone stringByReplacingCharactersInRange:zerosRange withString:@"+"];
    }
    
    if ([phone hasPrefix:@"1"]) {
        phone = [phone substringFromIndex:1];
    }
    
    return phone;
}

- (NSString*)countryCode {
    
    NSString *countryCode = nil;
    NSString *phone = [self clearedPhoneNumber];
    
    NSBundle *mrCountryBundle = [NSBundle bundleForClass:[MRCountryPicker class]];
    NSString *countriesPath = [mrCountryBundle pathForResource:@"SwiftCountryPicker.bundle/Data/countryCodes" ofType:@"json"];
    NSData *countriesData = [NSData dataWithContentsOfFile:countriesPath];
    NSError *parseError = nil;
    NSArray *countriesArray = [NSJSONSerialization JSONObjectWithData:countriesData options:0 error:&parseError];
    
    NSUInteger i = 0;
    while (!countryCode && i < countriesArray.count) {
        NSDictionary *country = countriesArray[i];
        NSString *dialCode = country[@"dial_code"];
        if ([phone hasPrefix:dialCode]) {
            countryCode = dialCode;
        }
        i++;
    }
    
    return countryCode;
}

- (BOOL)hasCountryCode:(NSString*)countryCode {
    if (countryCode) {
        NSString *phone = [self clearedPhoneNumber];
        return [phone hasPrefix:countryCode];
    }
    return YES;
}

@end
