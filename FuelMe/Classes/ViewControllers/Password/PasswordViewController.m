//
//  PasswordViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 11/11/12.
//  Copyright (c) 2012 FuelMe. All rights reserved.
//

#import "PasswordViewController.h"

#import "NSString+Utils.h"
#import "NSString+Valid.h"
#import "UITextField+Valid.h"
#import "PaddedTextField.h"

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = [@"Change Password" localized];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"SAVE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    doneButton.tintColor = [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self addEdgeInsetsToTextFields];
    
    UITapGestureRecognizer * tapGest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapGest];
    
    [self.password becomeFirstResponder];
}

- (NSString*)validateFields {
    NSString* value = nil;
    
    NSString* passwordValue = self.password.text;
    NSString* confirmValue = self.confirmPassword.text;
    
    if (passwordValue && [passwordValue isEqualToString:confirmValue]) {
        
        if (![self.password isValidPassword]) {
            value = [NSString stringWithFormat:[@"Please choose a password with at least %d or more characters." localized], (int)kMinPasswordLength];
        }
    } else {
        value = NSLocalizedString(@"Passwords do not match", @"");
    }
    return value;
}

- (void)save {
    [self.view endEditing:YES];
    NSString* message = [self validateFields];
    if (!message) {
        [self trackButtonUI:@"Save"];
        
        [self showHUD];
        [[RASessionManager sharedManager] updatePassword:self.password.text withCompletion:^(NSError *error) {
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            } else {
                [self showSuccessHUDandPOP];
            }
        }];
    } else {
        NSError *err = [NSError errorWithDomain:@"com.rideaustin.error.password" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey: message}];
        [RAAlertManager showErrorWithAlertItem:err
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.password becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.password){
        [self.confirmPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self save];
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)addEdgeInsetsToTextFields {
    CGRect rect = CGRectMake(0, 0, 15, 40);
    
    self.password.leftView = [[UIView alloc] initWithFrame:rect];
    self.password.leftViewMode = UITextFieldViewModeAlways;
    
    self.confirmPassword.leftView = [[UIView alloc] initWithFrame:rect];
    self.confirmPassword.leftViewMode = UITextFieldViewModeAlways;
}

@end
