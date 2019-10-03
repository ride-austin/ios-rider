//
//  RAPopUpView.h
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RAPopUpButton){
    RAPUButtonClose,
    RAPUButtonAccept,
    RAPUButtonDecline
};

@class RAPopUpView;

@protocol RAPopUpViewDelegate <NSObject>

- (void)popUpView:(RAPopUpView*)popUpView hasBeenDismissedWithButton:(RAPopUpButton)button;

@end

@interface RAPopUpView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *additionalView;
@property (weak, nonatomic) IBOutlet UIImageView *additionalIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfo1Label;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfo2Label;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *additionalViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorBottomConstraint;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, weak) id<RAPopUpViewDelegate> delegate;
@property (nonatomic, getter=isAdditionalViewHiddden) BOOL additionalViewHidden;

- (void)setAdditionalViewHidden:(BOOL)additionalViewHidden animated:(BOOL)animated;

@end

@interface RAPopUpView (PopUp)

- (void)show;
- (void)dismiss;

@end
