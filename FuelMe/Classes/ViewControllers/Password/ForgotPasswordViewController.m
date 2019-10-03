//
//  ForgotPasswordViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#import "NSString+Utils.h"
#import "PaddedTextField.h"
#import "UITextField+Valid.h"

@implementation ForgotPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButton = self.navigationItem.backBarButtonItem;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = [@"Forgot Password" localized];
    self.navigationController.navigationBar.accessibilityIdentifier = self.title;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
    self.emailTextField.leftView = paddingView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.isAccessibilityElement = YES;
    [super configureAllTapsWillDismissKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

#pragma mark - IBActions

- (IBAction)doForgotPassword:(id)sender {
    NSArray *errors = [self validate];
    if (!errors || self.emailTextField!=[errors lastObject]) {
        [self trackButtonUI:@"ForgotPasswordButton"];
        
        [self.view endEditing:YES];
        self.backButton.enabled = NO;
        [self showHUD];
        
        __weak ForgotPasswordViewController *weakSelf = self;
        [[RASessionManager sharedManager] recoverPasswordFromEmail:self.emailTextField.text withCompletion:^(NSError *error) {
            if (error) {
                [weakSelf hideHUD];
                weakSelf.backButton.enabled = YES;
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            } else {
                [weakSelf showSuccessHUDandPOP];
            }
        }];

    } else {
        [RAAlertManager showAlertWithTitle:[@"GENERIC_ERROR_TITLE" localized] message:[errors objectAtIndex:0]];
    }
}

- (NSArray*)validate {
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField ];
    } else {
        //FIX: RA-5062 - Fixed Email Validation to avoid test@test.com71~ or similar
        if(![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField];
        }
    }
    
    return nil;
}

@end
