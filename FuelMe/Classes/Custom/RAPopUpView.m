//
//  RAPopUpView.m
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPopUpView.h"
#import "KLCPopup.h"
static CGFloat const additionalViewHeight = 28.0;
static CGFloat const separatorTop = 14.0;
static CGFloat const separatorBottom = 14.0;

@interface RAPopUpView()

@property (nonatomic, strong) KLCPopup *popup;

- (IBAction)leftButtonHasBeenPressed:(UIButton*)sender;
- (IBAction)rightButtonHasBeenPressed:(UIButton*)sender;
- (IBAction)closeButtonHasBeenPressed:(UIButton*)sender;

@end

@implementation RAPopUpView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    [[NSBundle mainBundle] loadNibNamed:@"RAPopUpView" owner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (void)setAdditionalViewHidden:(BOOL)additionalViewHidden {
    [self setAdditionalViewHidden:additionalViewHidden animated:NO];
}


- (void)setAdditionalViewHidden:(BOOL)additionalViewHidden animated:(BOOL)animated {
    _additionalViewHidden = additionalViewHidden;
    
    self.separatorView.hidden = additionalViewHidden;
    self.additionalViewHeightConstraint.constant = additionalViewHidden ? 0 : additionalViewHeight;
    self.separatorTopConstraint.constant = additionalViewHidden ? 0 : separatorTop;
    self.separatorBottomConstraint.constant = additionalViewHidden ? 0 : separatorBottom;
    
    if (animated) {
        if (!additionalViewHidden) {
            self.additionalView.hidden = NO;
        }
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (additionalViewHidden) {
                self.additionalView.hidden = YES;
            }
        }];
    } else {
        [self layoutIfNeeded];
        self.additionalView.hidden = additionalViewHidden;
    }
    
}

- (void)leftButtonHasBeenPressed:(UIButton *)sender {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(popUpView:hasBeenDismissedWithButton:)]) {
        [self.delegate popUpView:self hasBeenDismissedWithButton:RAPUButtonAccept];
    }
}

- (void)rightButtonHasBeenPressed:(UIButton *)sender {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(popUpView:hasBeenDismissedWithButton:)]) {
        [self.delegate popUpView:self hasBeenDismissedWithButton:RAPUButtonDecline];
    }
}

- (void)closeButtonHasBeenPressed:(UIButton *)sender {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(popUpView:hasBeenDismissedWithButton:)]) {
        [self.delegate popUpView:self hasBeenDismissedWithButton:RAPUButtonClose];
    }
}

@end

@implementation RAPopUpView (PopUp)

- (void)show {
    self.popup = [KLCPopup popupWithContentView:self.contentView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    self.popup.dimmedMaskAlpha = 0.8;
    [self.popup show];
}

- (void)dismiss {
    [self.popup dismiss:YES];
}

@end
