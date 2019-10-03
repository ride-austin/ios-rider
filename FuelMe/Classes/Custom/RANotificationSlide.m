//
//  RANotificationSlide.m
//  Ride
//
//  Created by Robert on 5/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RANotificationSlide.h"

@interface RANotificationSlide ()

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) UIView *parentView;

@end

@implementation RANotificationSlide

+ (RANotificationSlide*)notificationWithMessage:(NSString*)message andParentView:(UIView*)view{
    RANotificationSlide *notificationSlide = [[RANotificationSlide alloc] initWithMessage:message andParentView:view];
    return notificationSlide;
}

- (instancetype)initWithMessage:(NSString*)message andParentView:(UIView*)view {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, -30, screenSize.width, 30);
    if (self = [self initWithFrame:frame]) {
        self.parentView = view;
        self.lblMessage.text = message;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"RANotificationSlide" owner:self options:nil];
        self.frame = frame;
        [self addSubview:self.view];
    
        //Constraints
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        
        [self addConstraints:@[leadingConstraint,trailingConstraint,topConstraint,bottomConstraint]];
    }
    return self;
}

- (void)show {
    [self.parentView addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }];
}

- (void)close {
    if (!self.superview) {
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, -30, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)close:(id)sender {
    [self close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCloseNotificationSlide)]) {
        [self.delegate didTapCloseNotificationSlide];
    }
}

@end
