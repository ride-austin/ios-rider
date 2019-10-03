//
//  UITextField+Helpers.m
//  Ride
//
//  Created by Roberto Abreu on 4/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UITextField+Helpers.h"

@implementation UITextField (Helpers)

- (void)addLeftPadding:(CGFloat)leftPadding {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftPadding, self.bounds.size.height)];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = view;
}

- (void)addRightPadding:(CGFloat)rightPadding {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightPadding, self.bounds.size.height)];
    self.rightViewMode = UITextFieldViewModeAlways;
    self.rightView = view;
}

@end
