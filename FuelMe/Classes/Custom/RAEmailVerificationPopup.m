//
//  RAEmailVerificationPopup.m
//  Ride
//
//  Created by Roberto Abreu on 11/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAEmailVerificationPopup.h"
#import "DNA.h"
#import "KLCPopup.h"

@interface RAEmailVerificationPopup()

//IBOutlets
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgStatusVerification;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSendEmailVerification;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnSendEmailHeight;

//Properties
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) EmailVerificationStatus status;
@property (strong, nonatomic) KLCPopup *popup;

@end

@implementation RAEmailVerificationPopup

#pragma mark - Init

+ (instancetype)popupWithEmail:(NSString *)email delegate:(id<RAEmailVerificationPopupDelegate>)delegate showingState:(EmailVerificationStatus)emailVerificationStatus {
    RAEmailVerificationPopup *emailVerificationPopup = [[RAEmailVerificationPopup alloc] initWithFrame:CGRectZero];
    emailVerificationPopup.delegate = delegate;
    emailVerificationPopup.email = email;
    [emailVerificationPopup updateWithEmailVerificationStatus:emailVerificationStatus];
    return emailVerificationPopup;
}

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
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self.contentView layoutIfNeeded];
    [self addSubview:self.contentView];
}

#pragma mark - Configure UI

- (void)updateWithEmailVerificationStatus:(EmailVerificationStatus)emailVerificationStatus {
    self.status = emailVerificationStatus;
    
    switch (emailVerificationStatus) {
        case EmailVerifiedStatus:
            [self configureVerifiedEmail];
            break;
        case EmailUnverifiedStatus:
            [self configureUnverifiedEmail];
            break;
    }
    
    [self layoutUIIfNeeded];
}

- (void)layoutUIIfNeeded {
    if (self.popup.isShowing) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.contentView layoutIfNeeded];
        }];
    } else {
        [self.contentView layoutIfNeeded];
    }
}

- (void)configureVerifiedEmail {
    self.imgStatusVerification.image = [UIImage imageNamed:@"email-verified-icon"];
    self.lblTitle.text = @"Thanks!";
    self.lblMessage.font = [UIFont fontWithName:FontTypeLight size:16.0];
    self.lblMessage.textAlignment = NSTextAlignmentCenter;
    self.lblMessage.text = @"Your have succesfully verified\nyour email address!";
    self.constraintBtnSendEmailHeight.constant = 0;
}

- (void)configureUnverifiedEmail {
    self.imgStatusVerification.image = [UIImage imageNamed:@"email-unverified-icon"];
    self.lblTitle.text = @"Verify your Email";
    
    NSDictionary *attributesDict = @{ NSForegroundColorAttributeName : UIColor.blackColor,
                                      NSFontAttributeName : [UIFont fontWithName:FontTypeLight size:14.0],
                                     };
    
    NSAttributedString *line1 = [[NSAttributedString alloc] initWithString:@"We'll send you an email verification to\n"
                                                                attributes:attributesDict];
    
    NSAttributedString *line2 = [[NSAttributedString alloc] initWithString:self.email
                                                                attributes:@{NSFontAttributeName : [UIFont fontWithName:FontTypeRegular size:16.0]}];
    
    
    NSAttributedString *line3 = [[NSAttributedString alloc] initWithString:@"\nPlease click on the link on the email to confirm it's you."
                                                                attributes:attributesDict];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] init];
    [message appendAttributedString:line1];
    [message appendAttributedString:line2];
    [message appendAttributedString:line3];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.paragraphSpacing = 8.0;
    style.alignment = NSTextAlignmentCenter;
    [message addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, message.length)];
    
    self.lblMessage.attributedText = message;
}

#pragma mark - IBActions

- (IBAction)sendEmailVerificationTapped:(id)sender {
    [self updateWithEmailVerificationStatus:EmailVerifiedStatus];
    if (self.delegate) {
        [self.delegate didTapSendEmailVerification];
    }
}

- (IBAction)closeTapped:(id)sender {
    [self dismiss];
}

#pragma mark - Methods

- (void)show {
    self.popup = [KLCPopup popupWithContentView:self.contentView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [self.popup show];
}

- (void)dismiss {
    [self.popup dismiss:YES];
}

@end
