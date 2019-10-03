//
//  UITextField+Valid.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "UITextField+Valid.h"
#import "NSString+Utils.h"

#import "RACategories.h"

@implementation UITextField (Valid)

- (BOOL)isEmpty {
    return [self.text isEmpty];
}

- (BOOL)isValidAlphaNumeric {
    return [self.text isValidAlphaNumeric];
}

- (BOOL)isValidPassword{
    return [self.text isValidPassword];
}

- (BOOL)isValidConfirmationPassword:(UITextField *)confirmPassword{
    return [self.text isValidConfirmationPassword:confirmPassword.text];
}

- (BOOL)isValidEmail{
    return [self.text isValidEmail];
}

- (BOOL)isValidEmailBasic{
    return [self.text isValidEmailBasic];
}

- (BOOL)isValidEnglish{
    return [self.text isValidEnglish];
}

- (BOOL)isValidEnglishName {
    return [self.text isValidEnglishName];
}

- (BOOL)isValidPhone {
    return [self.text isValidPhone];
}

@end
