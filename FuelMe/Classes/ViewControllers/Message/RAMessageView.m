//
//  RAMessageView.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/10/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAMessageView.h"
#import "UIView+CompatibleAnchor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DNA.h"

@interface RAMessageView()

@property (nonatomic, weak) id<RAMessageViewProtocol> controller;
@property (nonatomic) UIImageView *iconImageView;
@property (nonatomic) UIImageView *rightIconImageView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) BOOL canBeDismissedByUser;
@property (nonatomic) CAGradientLayer *shadowLayer;
@property (nonatomic) UIView *leftSpacerView;
@property (nonatomic) UIView *rightSpacerView;
@end

@implementation RAMessageView

// MARK: - Internal properties

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UIImageView *)rightIconImageView {
    if (!_rightIconImageView) {
        _rightIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-arrow"]];
        _rightIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightIconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:FontTypeLight size:14];
    }
    return _titleLabel;
}

- (CAGradientLayer *)shadowLayer {
    if (!_shadowLayer) {
        CGFloat radius = 5;
        UIColor *color = [UIColor blackColor];
        NSArray *colorsArray = @[(id)[color CGColor], (id)[[UIColor clearColor] CGColor]];
        
        _shadowLayer = [CAGradientLayer layer];
        _shadowLayer.colors = colorsArray;
        _shadowLayer.startPoint = CGPointMake(0.5, 0.0);
        _shadowLayer.endPoint = CGPointMake(0.5, 1.0);
        _shadowLayer.frame = CGRectMake(0, 0, self.bounds.size.width, radius);
        _shadowLayer.opacity = 0.2;
    }
    return _shadowLayer;
}

- (UIView *)leftSpacerView {
    if (!_leftSpacerView) {
        _leftSpacerView = [UIView new];
        _leftSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
        _leftSpacerView.hidden = YES;
    }
    return _leftSpacerView;
}

- (UIView *)rightSpacerView {
    if (!_rightSpacerView) {
        _rightSpacerView = [UIView new];
        _rightSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightSpacerView.hidden = YES;
    }
    return _rightSpacerView;
}

// MARK: - Setup
- (instancetype)initWithAttributedTitle:(NSAttributedString *)attributedTitle
                          textAlignment:(NSTextAlignment)textAlignment
                             andIconUrl:(NSURL *)iconURL
                        backgroundColor:(UIColor *)backgroundColor
                   canBeDismissedByUser:(BOOL)canBeDismissedByUser
                               callback:(void (^)(void))callback
                             controller:(id<RAMessageViewProtocol>)controller {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = backgroundColor;
        self.titleLabel.attributedText = attributedTitle;
        self.titleLabel.textAlignment = textAlignment;
        self.canBeDismissedByUser = canBeDismissedByUser;
        self.callback = callback;
        self.controller = controller;
        [self setupGestureRecognizers];
        [self setupShadow];
        if ([iconURL isKindOfClass:[NSURL class]]) {
            [self.iconImageView sd_setImageWithURL:iconURL];
            [self setupLayoutWithIcon:YES hasCallBack:callback != nil];
        } else {
            [self setupLayoutWithIcon:NO hasCallBack:callback != nil];
        }
    }
    return self;
}

- (void)setupGestureRecognizers {
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeMessageView:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMessageView:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)setupShadow {
    [self.layer insertSublayer:self.shadowLayer atIndex:0];
}

// MARK: - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateShadow];
}

- (void)updateShadow {
    CGRect frame = self.shadowLayer.frame;
    frame.size.width = self.bounds.size.width;
    self.shadowLayer.frame = frame;
}

- (void)setupLayoutWithIcon:(BOOL)hasIcon hasCallBack:(BOOL)hasCallback {
    [self addSubview:self.leftSpacerView];
    [self addSubview:self.rightSpacerView];
    [self addSubview:self.titleLabel];
    
    CGFloat imageToTextMargin = 14;
    NSMutableArray *constraints = [NSMutableArray arrayWithArray:
     @[
       [self.leftSpacerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
       [self.leftSpacerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kMainMargin],
       [self.leftSpacerView.trailingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
       
       [self.titleLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:kRAMessageViewTop],
       [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
       [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.titleLabel.bottomAnchor constant:kRAMessageViewBottom],
       
       [self.rightSpacerView.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
       [self.rightSpacerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
       [self.trailingAnchor constraintEqualToAnchor:self.rightSpacerView.trailingAnchor constant:kMainMargin]
       ]];
    if (hasIcon) {
        [self addSubview:self.iconImageView];
        [constraints addObjectsFromArray:
         @[
           [self.iconImageView.widthAnchor constraintEqualToConstant:44],
           [self.iconImageView.heightAnchor constraintEqualToConstant:34],
           [self.iconImageView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:kRAMessageViewTop],
           [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
           [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.iconImageView.bottomAnchor constant:kRAMessageViewBottom],
           [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.leftSpacerView.leadingAnchor],
           [self.leftSpacerView.trailingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:imageToTextMargin]
           ]];
    } else {
        [constraints addObject:[self.leftSpacerView.widthAnchor constraintEqualToConstant:0]];
    }
    
    if (hasCallback) {
        [self addSubview:self.rightIconImageView];
        [constraints addObjectsFromArray:
         @[
           [self.rightIconImageView.widthAnchor constraintEqualToConstant:9],
           [self.rightIconImageView.heightAnchor constraintEqualToConstant:14],
           [self.rightIconImageView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:kRAMessageViewTop],
           [self.rightIconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
           [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.rightIconImageView.bottomAnchor constant:kRAMessageViewBottom],
           
           [self.rightIconImageView.leadingAnchor constraintEqualToAnchor:self.rightSpacerView.leadingAnchor constant:imageToTextMargin],
           [self.rightIconImageView.trailingAnchor constraintEqualToAnchor:self.rightSpacerView.trailingAnchor]
           ]];
    } else {
        [constraints addObject:[self.rightSpacerView.widthAnchor constraintEqualToConstant:0]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
}


// MARK: - Internal Actions

- (void)didSwipeMessageView:(UISwipeGestureRecognizer *)swipeGesture {
    [self dismiss];
}

- (void)didTapMessageView:(UITapGestureRecognizer *)tapGesture {
    if (self.callback) self.callback();
    if (self.canBeDismissedByUser) [self dismiss];
}

// MARK: - External Actions

- (void)present {
    [NSLayoutConstraint activateConstraints:self.initialConstraints];
    if (self.unchangedConstraints) {
        [NSLayoutConstraint activateConstraints:self.unchangedConstraints];
    }
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:0.3+0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
         [NSLayoutConstraint deactivateConstraints:self.initialConstraints];
         [NSLayoutConstraint activateConstraints:self.finalConstraints];
         [self.superview layoutIfNeeded];
     } completion:^(BOOL finished) {
         if (self.controller) {
             [self.controller messageViewDidPresent:self];
         }
     }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.superview layoutIfNeeded];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:self];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             [NSLayoutConstraint deactivateConstraints:self.finalConstraints];
                             [NSLayoutConstraint activateConstraints:self.initialConstraints];
                             [self.superview layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             if (self.dismissCompletionCallback) self.dismissCompletionCallback();
                             if (self.controller) {
                                 [self.controller messageViewDidDismiss:self];
                             }
                             if (completion) {
                                 completion();
                             }
                         }];
    });
}
@end
