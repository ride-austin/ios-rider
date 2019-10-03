//
//  RACustomTextField.m
//  Ride
//
//  Created by Kitos on 6/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACustomTextField.h"

#import "UITextField+Helpers.h"

@interface RACustomTextField ()

@property (nonatomic, strong) UIColor *disabledBorderColor;
@property (nonatomic, strong) UIColor *enabledBorderColor;

- (void)setBorderColorEnabled:(BOOL)enabled;
- (void)setBorderColor:(UIColor*)color;
- (BOOL)borderEnabledForText:(NSString*)text;

@end

@interface RACustomTextField (Notifications)

- (void)textDidChangeNotification:(NSNotification*)notification;

@end

@implementation RACustomTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.enabledBorderColor = [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:1];
        self.disabledBorderColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];
        self.borderEnabled = NO;
        self.paddingOffset = 20;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    if (!self.hideBorder) {
        self.layer.borderWidth = 1;
    }

    self.layer.cornerRadius = 4;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    [super textRectForBounds:bounds];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, self.paddingOffset, 0, self.paddingOffset);
    return UIEdgeInsetsInsetRect(bounds, padding);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    [super editingRectForBounds: bounds];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, self.paddingOffset, 0, self.paddingOffset);
    return UIEdgeInsetsInsetRect(bounds, padding);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    [super placeholderRectForBounds:bounds];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, self.paddingOffset, 0, 20);
    return UIEdgeInsetsInsetRect(bounds, padding);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect originalRect = [super clearButtonRectForBounds:bounds];
    return CGRectOffset(originalRect, -10, 0); //shift the button 10 points to the left
}

- (void)setBorderEnabled:(BOOL)borderEnabled {
    BOOL enabledChanged = borderEnabled != _borderEnabled;
    _borderEnabled = borderEnabled;
    [self setBorderColorEnabled:borderEnabled];
    if (enabledChanged && [self.customDelegate respondsToSelector:@selector(textField:hasChangedBorderEnabled:)]) {
        [self.customDelegate textField:self hasChangedBorderEnabled:borderEnabled];
    }
}

- (void)setBorderColorEnabled:(BOOL)enabled {
    [self setBorderColor: enabled? self.enabledBorderColor : self.disabledBorderColor];
}

- (void)setBorderColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
}

- (BOOL)borderEnabledForText:(NSString *)text {
    return (text != nil && text.length > 0);
}

- (void)setHideBorder:(BOOL)hideBorder {
    _hideBorder = hideBorder;
    if (!self.hideBorder) {
        self.layer.borderWidth = 1;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end

@implementation RACustomTextField (Notifications)

- (void)textDidChangeNotification:(NSNotification *)notification {
    [self setBorderEnabled:[self borderEnabledForText:self.text]];
}

@end
