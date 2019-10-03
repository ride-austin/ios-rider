//
//  NSString+Valid.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMinPasswordLength 6
#define kStricterFilter NO

@interface NSString (Valid)

- (BOOL)isValidAlphaNumeric;
- (BOOL)isValidEnglish;
- (BOOL)isValidEnglishName;
- (BOOL)isValidPassword;
- (BOOL)isValidConfirmationPassword:(NSString*)confirmPassword;
- (BOOL)isValidEmail;
- (BOOL)isValidEmailBasic;
- (BOOL)isValidPhone;
- (NSString*)getNumbersFromString;
- (BOOL)isValidPhoneNumberLength;

@end
