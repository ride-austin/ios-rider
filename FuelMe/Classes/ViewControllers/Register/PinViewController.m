//
//  PinViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 2/27/15.
//  Copyright (c) 2015 FuelMe LLC. All rights reserved.
//

#import "PinViewController.h"

#import "ErrorReporter.h"
#import "NSString+Utils.h"
#import "RAPhoneVerificationAPI.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "RAAlertManager.h"

@interface PinViewController ()

@property (nonatomic) NSString *token;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *mobile;
@property (nonatomic) NSString *password;

@end

@implementation PinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 12.0, *)) {
        self.oneTimePinField.textContentType = UITextContentTypeOneTimeCode;
    }
    
    self.title = [@"Verify Mobile" localized];
    self.navigationController.navigationBar.accessibilityIdentifier = self.title;
    
    self.titleLabel.text = [NSString stringWithFormat:[@"that was sent to %@" localized], self.mobile];
    
    [self.oneTimePinField becomeFirstResponder];
    
    [self.btnResendText setEnabled:NO];
    [self enableButtonWithDelay];
    
    [self.oneTimePinField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (IBAction)resendText:(id)sender {
    [self showHUD];
     __weak PinViewController *weakSelf = self;
    
    [self.btnResendText setEnabled:NO];
    [RAPhoneVerificationAPI postVerifyPhoneNumber:self.mobile withCompletion:^(NSString *token, NSError *error) {
        [weakSelf enableButtonWithDelay];
        __strong PinViewController *strongSelf = weakSelf;
        [strongSelf hideHUD];
        if (token) {
            self.token = token;
        } else {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        }
    }];
}

- (void)enableButtonWithDelay {
    [self performSelector:@selector(enableButton) withObject:self afterDelay:10];
}

- (void)enableButton {
    [self.btnResendText setEnabled:YES];
}

- (IBAction)changeMobile:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithToken:(NSString *)token
             mobile:(NSString *)mobile
           delegate:(id<PhoneVerificationDelegate>)delegate {
    self = [super init];
    if (self) {
        self.token      = token;
        self.mobile     = mobile;
        self.delegate   = delegate;
    }
    return self;
}

- (IBAction)doCancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)validatePin {
    [self showHUD];
    [self.oneTimePinField setEnabled:NO];
    NSString *pin = self.oneTimePinField.text;
    
    __weak PinViewController *weakSelf = self;
    [RAPhoneVerificationAPI postVerifyCode:pin token:self.token withCompletion:^(BOOL success, NSError *error) {
        __strong PinViewController *strongSelf = weakSelf;
        [self.oneTimePinField setEnabled:YES];
        if (success) {
            [self.btnResendText setEnabled:NO];
            [self didVerifyPhone];
        } else {
            // Ask user to re-attempt verification
            [strongSelf resetState];
            [weakSelf hideHUD];
            
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        }
    }];
}

- (void)didVerifyPhone {
    [self.delegate phoneVerificationDidSucceed];
}

- (void)resetState {
    self.oneTimePinField.text = @"";
    [self.oneTimePinField becomeFirstResponder];
}

-(void) textFieldDidChange: (UITextField *)textField {
    if ([textField.text length] >= 4) {
         [self validatePin];
    }
}
@end
