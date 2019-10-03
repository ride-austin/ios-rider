//
//  NSString+Valid.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSString+Valid.h"

@implementation NSString (Valid)

//check valid english text (not Russian or whatever)
- (BOOL)isValidEnglish {
    static NSPredicate *predicate = nil;
    if(!predicate) {
        NSString *nameRegex = @"[A-Za-z]+";
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    }
    return [predicate evaluateWithObject:self];
}

- (BOOL)isValidEnglishName {
    static NSPredicate *predicate = nil;
    if(!predicate) {
        NSString *nameRegex = @"[A-Za-z ,.'-]+";
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    }
    return [predicate evaluateWithObject:self];
}

// check for valid alpha/numeric
- (BOOL)isValidAlphaNumeric {
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

//check for valid password
- (BOOL)isValidPassword {
    BOOL valid = YES;
    if (self.length < kMinPasswordLength) {
        valid = NO;
    }
    
    return valid;
}

- (BOOL)isValidConfirmationPassword:(NSString*)confirmPassword {
    BOOL valid = NO;
    if (self && [self isEqualToString:confirmPassword]) {
        valid = YES;
    }
    
    return valid;
}

// check for valid email
// email Validation http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/

- (BOOL)isValidEmail {
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = kStricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

//check valid email from old code base
- (BOOL)isValidEmailBasic {
    static NSPredicate *emailTest = nil;
    if(!emailTest) {
        emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"];
    }
    return [emailTest evaluateWithObject:self];
}

//check for valid Phone Number lenght with 8 - 15 digits
- (BOOL)isValidPhone {
    static NSPredicate *phoneTest = nil;
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{8,15}$";
    if(!phoneTest) {
        phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    }
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)isValidPhoneNumberLength {
    return [self getNumbersFromString].length >= 8;
}

- (NSString*)getNumbersFromString {
    NSArray* numbers = [self componentsSeparatedByCharactersInSet:
                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    return [numbers componentsJoinedByString:@""];
}

@end
