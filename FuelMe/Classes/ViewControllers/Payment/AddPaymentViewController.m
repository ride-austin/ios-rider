//
//  AddPaymentViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/18/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "AddPaymentViewController.h"

#import "ErrorReporter.h"
#import "PersistenceManager.h"
#import "RARiderDataModel.h"

typedef NS_ENUM(NSUInteger, STPFormTag) {
    STPFormTagExpirationDate = 1,
    STPFormTagCVC = 2
};

static NSString *const kScreenTitle = @"Add Payment";

@interface AddPaymentViewController () <STPPaymentCardTextFieldDelegate>

@property (nonatomic) STPCardParams *cardParams;
@property (nonatomic) UIBarButtonItem *saveBarButtomItem;

@end

@implementation AddPaymentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self showCardExpirationAlertIfNeeded];
}

#pragma mark - Configure UI

- (void)configureUI {
    self.title = kScreenTitle;
    self.navigationController.navigationBar.accessibilityIdentifier = kScreenTitle;
    [self configureStripeControl];
    [self configureNavigationBarSaveButton];
}

- (void)configureStripeControl {
    UIFont *font = [UIFont fontWithName:FontTypeLight size:14.5];
    UIColor *textColor = [UIColor colorWithRed:44.0/255.0 green:50.0/255.0 blue:60.0/255.0 alpha:1.0];
    self.stripeView.font = font;
    self.stripeView.textColor = textColor;
    self.stripeView.cornerRadius = 3;
    self.stripeView.borderWidth = .5;
    self.stripeView.accessibilityHint = @"Enter your 16-digit card number, month year and cvv continuously. Tap Save in the upper right";
}

- (void)configureNavigationBarSaveButton {
    self.saveBarButtomItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.saveBarButtomItem;
    [self.saveBarButtomItem setTintColor:[UIColor blueColor]];
    self.saveBarButtomItem.enabled = NO;
}

- (void)enableUIControl {
    [self.stripeView setEnabled:YES];
    [self.saveBarButtomItem setEnabled:YES];
}

- (void)disableUIControl {
    [self.stripeView setEnabled:NO];
    [self.saveBarButtomItem setEnabled:NO];
}

#pragma mark - IBActions

- (void)saveButtonPressed:(UIBarButtonItem*)button {
    [self showHUD];
    [self.stripeView resignFirstResponder];
    [self disableUIControl];
    __weak AddPaymentViewController *weakSelf = self;
    [[STPAPIClient sharedClient] createTokenWithCard:self.cardParams completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error) {
            [weakSelf hideHUD];
            [ErrorReporter recordError:error withDomainName:STRIPECreateToken];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            [weakSelf enableUIControl];
        } else {
            RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
            __weak AddPaymentViewController *weakSelf = self;
            [rider addCard:token.tokenId withCompletion:^(RACardDataModel *card, NSError *error) {
                [weakSelf hideHUD];
                
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                    [weakSelf enableUIControl];
                    return;
                }
                
                if ([rider cards].count > 1) {
                    [weakSelf showPrimaryCardDialogForCard:card];
                } else {
                    if (weakSelf.delegate) {
                        [weakSelf.delegate didAddPaymentMethod];
                    }
                    [weakSelf showSuccessHUDandPOP];
                }
            }];
        }
    }];
}

- (void)showPrimaryCardDialogForCard:(RACardDataModel*)card {
    __weak AddPaymentViewController *weakSelf = self;
    RAAlertOption *options = [RAAlertOption optionWithState:StateActive];
    
    [options addAction:[RAAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        [weakSelf showHUD];
        RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
        [rider setPrimaryCard:card withCompletion:^(NSError *error) {
            if (error) {
                [weakSelf hideHUD];
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
            } else {
                [weakSelf showSuccessHUDandPOP];
            }
        }];
    }]];
    
    [options addAction:[RAAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
        [weakSelf showSuccessHUDandPOP];
    }]];
    
    [RAAlertManager showAlertWithTitle:@"Primary Credit Card" message:@"Do you want to set this credit card as primary?" options:options];
}

#pragma mark - STPPaymentCardTextFieldDelegate

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    BOOL isCardParamsValid = textField.isValid;
    self.cardParams = isCardParamsValid ? textField.cardParams : nil;
    [self.saveBarButtomItem setEnabled:isCardParamsValid];
}

- (void)paymentCardTextFieldDidEndEditingNumber:(STPPaymentCardTextField *)textField {
    [self paymentCardTextField:textField focusOn:STPFormTagExpirationDate];
}

- (void)paymentCardTextFieldDidEndEditingExpiration:(STPPaymentCardTextField *)textField {
    [self paymentCardTextField:textField focusOn:STPFormTagCVC];
}

/**
 *  @brief this will change the accessibility focus to the textField with tag STPFormTag RA-8327
 */
- (void)paymentCardTextField:(STPPaymentCardTextField *)textField focusOn:(STPFormTag)stpFormTextFieldTag {
    if (UIAccessibilityIsVoiceOverRunning()) {
        for (UIView *view in [textField subviews]) {
            if (view && [view isKindOfClass:[UIView class]]) {
                for (UITextField *stpForm in view.subviews) {
                    if ([stpForm isKindOfClass:[UITextField class]] && stpForm.tag == stpFormTextFieldTag) {
                        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, stpForm);
                        return;
                    }
                }
            }
        }
    }
}

#pragma mark - Helpers

- (void)showCardExpirationAlertIfNeeded {
    RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
    if (rider.primaryCard && [rider.primaryCard.cardExpired boolValue]) {
        [RAAlertManager showAlertWithTitle:@"" message:@"Sorry your card has expired, please add a valid card" options:[RAAlertOption optionWithState:StateActive]];
    }
}

@end
