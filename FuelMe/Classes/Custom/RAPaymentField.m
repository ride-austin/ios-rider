//
//  RAPaymentField.m
//  Ride
//
//  Created by Roberto Abreu on 3/8/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAPaymentField.h"
#import "DNA.h"
#import <Stripe/STPCardValidator.h>
#import "NSString+Valid.h"

@interface RAPaymentField()<UITextFieldDelegate>

@property (nonatomic) UILabel *lbTitle;
@property (nonatomic) UITextField *textField;

@end

@implementation RAPaymentField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self configureContainerUI];
    [self configureSubviews];
}

- (void)configureContainerUI {
    CGFloat width = 0.7;
    CALayer *layer = [CALayer new];
    layer.borderColor = [UIColor colorWithWhite:0 alpha:0.12].CGColor;
    layer.borderWidth = width;
    layer.frame = CGRectMake(0, self.frame.size.height-width, self.frame.size.width, width);
    [self.layer addSublayer:layer];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)configureSubviews {
    UIColor *textColor = [UIColor colorWithRed:86.0/255.0 green:86.0/255.0 blue:86.0/255.0 alpha:1.0];
    if (!self.lbTitle) {
        CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 20);
        
        self.lbTitle = [[UILabel alloc] initWithFrame:frame];
        self.lbTitle.font = [UIFont fontWithName:FontTypeRegular size:12.0];
        self.lbTitle.textColor = textColor;
        self.lbTitle.alpha = 0.5;
        [self addSubview:self.lbTitle];
    }
    
    if (!self.textField) {
        CGRect frame = CGRectMake(0, self.lbTitle.frame.size.height, self.bounds.size.width, 18);
        self.textField = [[UITextField alloc] initWithFrame:frame];
        self.textField.font = [UIFont fontWithName:FontTypeLight size:14.0];
        self.textField.textColor = textColor;
        self.textField.delegate = self;
        [self addSubview:self.textField];
    }
    
    [self updateFieldProperties];
}

- (void)updateFieldProperties {
    self.lbTitle.text = self.titleByType;
    self.textField.keyboardType = UIKeyboardTypePhonePad;
    self.textField.textColor = [self textColor];
    self.textField.placeholder = [self placeholderText];
    self.textField.textAlignment = [self aligmentByType];
    self.textField.enabled = [self enabledByType];
    self.textField.leftView = [self leftViewByType];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.text = [self textFromCardByType];
}

- (void)setType:(RAPaymentFieldType)type {
    _type = type;
    [self updateFieldProperties];
}

- (void)setPaymentItem:(PaymentItem *)paymentItem {
    _paymentItem = paymentItem;
    [self updateFieldProperties];
}

- (NSString *)month {
    return [self monthFromExpirationText:self.textField.text];
}

- (NSString *)year {
    return [self yearFromExpirationText:self.textField.text];
}

- (BOOL)isValid {
    switch (self.type) {
        case RAPaymentNumberFieldType:
        case RAPaymentCVVFieldType:
            return YES;
        case RAPaymentExpirationFieldType:{
            return [STPCardValidator validationStateForExpirationMonth:[self month]] == STPCardValidationStateValid &&
                   [STPCardValidator validationStateForExpirationYear:[self year] inMonth:[self month]] == STPCardValidationStateValid;
        }
    }
}

#pragma mark - Configure TextField UI

- (BOOL)becomeFirstResponder {
    BOOL becomeFirstResponderValue = [super becomeFirstResponder];
    if (!becomeFirstResponderValue) {
        [self.textField becomeFirstResponder];
    }
    return becomeFirstResponderValue;
}

- (NSString *)titleByType {
    switch (self.type) {
        case RAPaymentNumberFieldType: return @"Card Number";
        case RAPaymentExpirationFieldType: return @"Exp. Date";
        case RAPaymentCVVFieldType: return @"";
    }
}
- (NSString *)placeholderText {
    switch (self.type) {
        case RAPaymentNumberFieldType:
            return @"4242 4242 4242 4242";
        case RAPaymentExpirationFieldType:
            return @"MM/YY";
        case RAPaymentCVVFieldType:
            return @"CVV";
    }
}

- (NSTextAlignment)aligmentByType {
    switch (self.type) {
        case RAPaymentNumberFieldType:
        case RAPaymentExpirationFieldType:
        case RAPaymentCVVFieldType:
            return NSTextAlignmentLeft;
    }
}

- (UIColor *)textColor {
    return [self enabledByType] ? [UIColor blackColor] : [UIColor lightGrayColor];
}

- (UIColor *)errorTextColor {
    return [UIColor redColor];
}

- (BOOL)enabledByType {
    switch (self.type) {
        case RAPaymentNumberFieldType:
        case RAPaymentCVVFieldType:
            return NO;
        case RAPaymentExpirationFieldType:
            return YES;
    }
}

- (UIView *)leftViewByType {
    switch (self.type) {
        case RAPaymentNumberFieldType:{
            CGFloat brandWidth = 27;
            CGFloat brandHeight = 18;
            CGFloat margin = 6;
            
            UIView *brandCardContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, brandWidth + margin, self.bounds.size.height)];
            
            UIImageView *brandCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, brandWidth, brandHeight)];
            CGPoint center = brandCardImageView.center;
            center.y = brandCardContainer.center.y;
            brandCardImageView.center = center;
            brandCardImageView.contentMode = UIViewContentModeScaleAspectFit;
            brandCardImageView.image = self.paymentItem.iconItem;
            
            [brandCardContainer addSubview:brandCardImageView];
            
            return brandCardContainer;
        }
        case RAPaymentExpirationFieldType:
        case RAPaymentCVVFieldType:
            return nil;
    }
}

- (NSString *)textFromCardByType {
    switch (self.type) {
        case RAPaymentNumberFieldType:
            return self.paymentItem.text;
        case RAPaymentExpirationFieldType:
            return self.paymentItem.expiration;
        case RAPaymentCVVFieldType:
            return nil;
    }
}

- (void)textFieldInvalidAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[@0, @5, @-5, @2.5, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    [self.textField.layer addAnimation:animation forKey:@"shake"];
}

#pragma mark - Helpers Values

- (NSString *)monthFromExpirationText:(NSString *)expirationText {
    if (self.type != RAPaymentExpirationFieldType) {
        return nil;
    }
    NSString *expirationNumbers = [STPCardValidator sanitizedNumericStringForString:expirationText];
    NSString *expirationMonth = [expirationNumbers substringToIndex:MIN(expirationNumbers.length, 2)];
    if ([expirationMonth length] == 1 && ![expirationMonth isEqualToString:@"0"] && ![expirationMonth isEqualToString:@"1"]) {
        expirationMonth = [NSString stringWithFormat:@"0%@", expirationMonth];
    }
    return expirationMonth;
}

- (NSString *)yearFromExpirationText:(NSString *)expirationText {
    if (self.type != RAPaymentExpirationFieldType) {
        return nil;
    }
    NSString *expirationNumbers = [STPCardValidator sanitizedNumericStringForString:expirationText];
    NSString *expirationYear = @"";
    if (expirationNumbers.length > 2) {
        expirationYear = [expirationNumbers substringFromIndex:2];
        expirationYear = [expirationYear substringToIndex:MIN(expirationYear.length, 2)];
    }
    return expirationYear;
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL deleting = (range.location == textField.text.length - 1 && range.length == 1 && [string isEqualToString:@""]);
    NSString *textResult = @"";
    if (deleting) {
        NSString *sanitized = [STPCardValidator sanitizedNumericStringForString:textField.text];
        textResult = [sanitized substringToIndex:MIN(sanitized.length, sanitized.length - 1)];
    } else {
        textResult = [[textField.text stringByReplacingCharactersInRange:range withString:string] getNumbersFromString];
    }
    
    textField.text = [self formatByTypeWithText:textResult];
    [self updateUIByTypeWithText:textResult];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return NO;
}

- (NSString *)formatByTypeWithText:(NSString *)currentText {
    switch (self.type) {
        case RAPaymentExpirationFieldType: {
            NSString *expirationMonth = [self monthFromExpirationText:currentText];
            NSString *expirationYear = [self yearFromExpirationText:currentText];
            
            NSMutableArray *expirationComponents = [NSMutableArray array];
            if (expirationMonth && ![expirationMonth isEqualToString:@""]) {
                [expirationComponents addObject:expirationMonth];
            }
            
            if ([STPCardValidator validationStateForExpirationMonth:expirationMonth] == STPCardValidationStateValid) {
                [expirationComponents addObject:expirationYear];
            }
            return [expirationComponents componentsJoinedByString:@"/"];
        }
        default:
            return currentText;
    }
}

- (void)updateUIByTypeWithText:(NSString *)currentText {
    switch (self.type) {
        case RAPaymentExpirationFieldType:{
            NSString *expirationMonth = [self monthFromExpirationText:currentText];
            NSString *expirationYear = [self yearFromExpirationText:currentText];
            if ([STPCardValidator validationStateForExpirationMonth:expirationMonth] == STPCardValidationStateInvalid ||
                [STPCardValidator validationStateForExpirationYear:expirationYear inMonth:expirationMonth] == STPCardValidationStateInvalid) {
                self.textField.textColor = [self errorTextColor];
                [self textFieldInvalidAnimation];
            } else {
                self.textField.textColor = [self textColor];
            }
            break;
        }
        default:
            break;
    }
}

@end
