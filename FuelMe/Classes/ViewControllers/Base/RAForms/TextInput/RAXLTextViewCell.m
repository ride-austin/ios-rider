//
//  RAXLTextViewCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAXLTextViewCell.h"

#import "UIColor+raColors.h"

NSString * const XLFormRowDescriptorTypeRAXLTextViewCell = @"XLFormRowDescriptorTypeRAXLTextViewCell";

@implementation RAXLTextViewCell

+ (void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeRAXLTextViewCell : NSStringFromClass(self.class)};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.layer.borderWidth = 1;
    self.placeholderView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor textFieldBorder].CGColor;
    self.placeholderView.layer.borderColor = [UIColor textFieldBorder].CGColor;
}

@end
