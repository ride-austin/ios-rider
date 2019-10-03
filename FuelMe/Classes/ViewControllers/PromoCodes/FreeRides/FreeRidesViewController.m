//
//  FreeRidesViewController.m
//  Ride
//
//  Created by Kitos on 6/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "FreeRidesViewController.h"

#import <MessageUI/MessageUI.h>

#import "AssetCityManager.h"
#import "NSString+Utils.h"
#import "RAPromoCodeAPI.h"
#import "RAPromoViewModel.h"
#import "SocialMediaTableViewController.h"

#import "UILabel+Copyable.h"

@interface FreeRidesViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (nonatomic) RAPromoViewModel *promoViewModel;
@property (nonatomic, weak) IBOutlet UILabel *promoLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;
@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *socialBtn;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (nonatomic, strong) UIColor *emailEnabledColor;
@property (nonatomic, strong) UIColor *emailDisabledColor;
@property (nonatomic, strong) UIColor *smsEnabledColor;
@property (nonatomic, strong) UIColor *smsDisabledColor;
@property (nonatomic, strong) UIColor *socialEnabledColor;
@property (nonatomic, strong) UIColor *socialDisabledColor;

@property (nonatomic) BOOL isViewAvailable;

- (IBAction)emailTouched:(UIButton *)sender;
- (IBAction)smsTouched:(UIButton *)sender;
- (IBAction)shareOnSocialMedia:(UIButton *)sender;

@end

@interface FreeRidesViewController (FetchData)

- (void)fetchData;

@end

@interface FreeRidesViewController (UIUpdates)

- (void)setButtonsEnabled:(BOOL)enabled;

@end

@interface FreeRidesViewController (MessageDelegate) <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation FreeRidesViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isViewAvailable = YES;
    
    self.title = [@"Referral Discounts" localized];
    
    self.emailEnabledColor = [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:1];
    self.emailDisabledColor = [UIColor grayColor];
    self.smsEnabledColor = [UIColor colorWithRed:46.0/255.0 green:51.0/255.0 blue:63.0/255.0 alpha:1];
    self.smsDisabledColor = [UIColor grayColor];
    self.socialEnabledColor = [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:1];
    self.socialDisabledColor = [UIColor grayColor];
    
    self.imgLogo.image = [AssetCityManager logoImageCurrentCity];
    
    [self setButtonsEnabled:NO];
    self.promoLabel.copyingEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isViewAvailable = YES;
    [self fetchData];
    
    __weak FreeRidesViewController *weakSelf = self;

    [[RANetworkManager sharedManager] addReachabilityObserver:self statusChangedBlock:^(RANetworkReachability networkReachability) {
       if (networkReachability == RANetworkReachable) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf fetchData];
           });
       } else {
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf setButtonsEnabled:NO];
           });
       }
   }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewAvailable = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)emailTouched:(UIButton *)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:self.promoViewModel.emailTitle];
        [picker setMessageBody:self.promoViewModel.emailBody isHTML:YES];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSString *errorMessage = [@"Your device does not allow sending email. Please send an email using a different device/computer" localized];
        [RAAlertManager showErrorWithAlertItem:errorMessage
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
    }

}

- (IBAction)smsTouched:(UIButton *)sender {
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = self.promoViewModel.smsBody;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Your device does not allow sending text messages." localized]
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
    }
}

- (IBAction)shareOnSocialMedia:(UIButton *)sender {
    SocialMediaTableViewController *smtvc = [[SocialMediaTableViewController alloc]init];
    smtvc.sharingText = self.promoViewModel.smsBody;
    smtvc.downloadURL = self.promoViewModel.downloadURL;
    [self.navigationController pushViewController:smtvc animated:YES];
}

@end

@implementation FreeRidesViewController (FetchData)

- (void)fetchData {
    
    //avoid crash on showHUD when click back and VC is not available
    if (!self.isViewAvailable) {
        return;
    }
    
    [self setButtonsEnabled:NO];

    [self showHUD];
    
    __weak FreeRidesViewController *weakSelf = self;
    [RAPromoCodeAPI getMyPromoCodeWithCompletion:^(RAPromoCode *promoCode, NSError *error) {
        if (!error) {
            weakSelf.promoLabel.text = promoCode.codeLiteral;
            weakSelf.promoViewModel = [RAPromoViewModel viewModelWithPromoCode:promoCode
                                                                   andTemplate:[ConfigurationManager shared].global.referRider];
        } else {
            weakSelf.promoLabel.text = [@"Promo Code Error" localized];
            weakSelf.promoViewModel = [RAPromoViewModel viewModelWithPromoCode:nil
                                                                   andTemplate:[ConfigurationManager shared].global.referRider];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
        }
        
        weakSelf.detailsLabel.text = weakSelf.promoViewModel.detailText;
        [weakSelf setButtonsEnabled:(error==nil)];
        [weakSelf hideHUD];
    }];

}

@end

@implementation FreeRidesViewController (UIUpdates)

- (void)setButtonsEnabled:(BOOL)enabled {
    self.emailBtn.enabled = enabled;
    self.emailBtn.backgroundColor = enabled ? self.emailEnabledColor : self.emailDisabledColor;
    self.smsBtn.enabled = enabled;
    self.smsBtn.backgroundColor = enabled ? self.smsEnabledColor : self.smsDisabledColor;
    self.socialBtn.enabled = enabled;
    [self.socialBtn setTitleColor:(enabled ? self.socialEnabledColor : self.socialDisabledColor) forState:UIControlStateNormal];
}

@end

@implementation FreeRidesViewController (MessageDelegate)

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
        }
        else {
            [self hideHUD: (result == MFMailComposeResultSent)];
            if (result == MFMailComposeResultFailed) {
                NSError *err = [NSError errorWithDomain:@"com.rideaustin.error.promoshare" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:[@"An error occurred. Cannot send the email." localized]}];
                [RAAlertManager showErrorWithAlertItem:err
                                            andOptions:[RAAlertOption optionWithState:StateActive]];
            }
        }
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultFailed) {
            [self hideHUD];
            NSError *err = [NSError errorWithDomain:@"com.rideaustin.error.promoshare" code:-2 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:[@"An error occurred. Cannot send the SMS." localized]}];
            [RAAlertManager showErrorWithAlertItem:err andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [self hideHUD: (result == MessageComposeResultSent)];
        }
    }];
}

@end
