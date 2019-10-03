//
//  RAAddressButton.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAAddressButton.h"

#import "NSString+Utils.h"
#import "UIColor+raColors.h"

@implementation RAAddressButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureDefaults];
    }
    return self;
}

- (void)configureDefaults {
    CGFloat imageWidth = 10;
    CGFloat leftMargin = 25;
    CGFloat rightMargin = 22;
    CGFloat leftInset = leftMargin + imageWidth + rightMargin;
    self.titleEdgeInsets = UIEdgeInsetsMake(0, leftInset, 0, rightMargin);
    if (@available(iOS 11.0, *)) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    } else {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
}
- (NSString *)text {
    if ([self.titleLabel.text isEqualToString:self.placeholder]) {
        return nil;
    } else {
        return self.titleLabel.text;
    }
}

- (void)setText:(NSString *)text {
    UIColor *filledColor = [UIColor blackColor];

    if ([text isKindOfClass:NSString.class] && text.length > 0) {
        [self setTitleColor:filledColor forState:UIControlStateNormal];
        [self setTitle:text forState:UIControlStateNormal];
    } else {
        [self setTitleColor:[UIColor placeholderColor] forState:UIControlStateNormal];
        [self setTitle:self.placeholder forState:UIControlStateNormal];
    }
}

#pragma mark - Accessibility

- (NSString *)accessibilityIdentifier {
    switch (self.fieldType) {
        case RAPickerAddressPickupFieldType:
            return @"txtPickup";
        case RAPickerAddressDestinationFieldType:
            return @"txtDestination";
    }
}

- (NSString *)accessibilityLabel {
    NSMutableString *string = [NSMutableString new];
    switch (self.fieldType) {
        case RAPickerAddressPickupFieldType:
            [string appendString:[@"Your pickup address" localized]];
            break;
        case RAPickerAddressDestinationFieldType:
            [string appendString:[@"Your destination" localized]];
            break;
    }
    if (self.text) {
        [string appendString:[@" is " localized]];
        [string appendString:self.text];
    } else {
        [string appendString:[@" is empty" localized]];
    }
    
    return string;
}

- (NSString *)accessibilityHint {
    switch (self.fieldType) {
        case RAPickerAddressPickupFieldType:
            return [@"Tap to change your pickup address." localized];
        case RAPickerAddressDestinationFieldType:
            return [@"Tap to change your destination address." localized];
    }
}

@end
