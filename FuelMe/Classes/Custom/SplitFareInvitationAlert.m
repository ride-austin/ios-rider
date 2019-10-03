//
//  SplitFareInvitationAlert.m
//  Ride
//
//  Created by Abdul Rehman on 31/08/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SplitFareInvitationAlert.h"

#import "SplitFareManager.h"

#import "KLCPopup.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SplitFareInvitationAlert()

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Contact * tempContact;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightVAcceptDecline;
@property (weak, nonatomic) IBOutlet UIView *vAcceptDecline;
@property (weak, nonatomic) IBOutlet UIButton *btOK;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (nonatomic, strong) KLCPopup *popup;
@property (nonatomic, copy)SplitFareActionBlock actionBlock;

- (IBAction)btnDeclinePressed:(UIButton *)sender;
- (IBAction)btnAcceptPressed:(UIButton *)sender;

@end

@implementation SplitFareInvitationAlert

+ (SplitFareInvitationAlert*)splitPopupWithContact:(Contact*)contact pushType:(SFPushType)pushType completion:(SplitFareActionBlock)handler{
    
    SplitFareInvitationAlert *alert = [[SplitFareInvitationAlert alloc]initWithFrame:CGRectMake(0, 0, 290, 206)];
    alert.actionBlock = handler;
    
    switch (pushType) {
        case SFPushTypeAccepted:
            alert.constraintHeightVAcceptDecline.constant = 50;
            alert.btOK.hidden           = NO;
            alert.vAcceptDecline.hidden = YES;
            alert.lblAlertTitle.text = @"SPLIT FARE ACCEPTED";
            alert.lblUserName.text = [NSString stringWithFormat:@"by %@",contact.firstName];
            break;
        case SFPushTypeDeclined:
            alert.constraintHeightVAcceptDecline.constant = 50;
            alert.btOK.hidden           = NO;
            alert.vAcceptDecline.hidden = YES;
            alert.lblAlertTitle.text = @"SPLIT FARE DECLINED";
            alert.lblUserName.text = [NSString stringWithFormat:@"by %@",contact.firstName];
            break;
        case SFPushTypeRequested:
            alert.constraintHeightVAcceptDecline.constant = 70;
            alert.btOK.hidden           = YES;
            alert.vAcceptDecline.hidden = NO;
            alert.lblAlertTitle.text = @"SPLIT FARE";
            alert.lblUserName.text = [NSString stringWithFormat:@"With %@",contact.firstName];
            break;
    }
    
    if (contact.image == nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:contact.imageURL];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [alert.activityIndicator startAnimating];
        [alert.imgUserPhoto setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"person_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [alert.activityIndicator stopAnimating];
            contact.image = image;
            alert.imgUserPhoto.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [alert.activityIndicator stopAnimating];
        }];
    } else {
        [alert.imgUserPhoto setImage:contact.image];
    }
    
    alert.tempContact= contact;
    alert.popup = [KLCPopup popupWithContentView:alert showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];

    return  alert;
}

#pragma mark- Init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SplitFareInvitationAlert" owner:self options:nil];
        self.view.frame = frame;
        self.view.layer.cornerRadius = 8;
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.view.layer.cornerRadius = 8;
    [self addSubview:self.view];
}

- (void)show {
    //Close the keyboard (in case if open)
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.popup show];
}

#pragma mark- Button Actions

- (IBAction)btnDeclinePressed:(UIButton *)sender {
    [self.popup dismiss:YES];
    if (self.actionBlock) {
        self.actionBlock(self.splitFareId,NO);
    }
}

- (IBAction)btnAcceptPressed:(UIButton *)sender {
    [self.popup dismiss:YES];
    if (self.actionBlock) {
        self.actionBlock(self.splitFareId,YES);
        
    }
}

@end
