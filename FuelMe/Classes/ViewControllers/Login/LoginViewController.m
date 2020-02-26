//
//  LoginViewController.m
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "LoginViewController.h"

#import "ErrorReporter.h"
#import "NSString+Utils.h"
#import "PaddedTextField.h"
#import "RegisterInfoViewController.h"
#import "NSString+Valid.h"
#import "UITextField+Helpers.h"
#import "UITextField+Valid.h"
#import "UIBarButtonItem+RAFactory.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

NSString * const kFacebookSignin = @"kFacebookSignin";

@interface LoginViewController ()

@property (nonatomic) UIBarButtonItem *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginFacebook;
@property (nonatomic) BOOL fbLoginProcessStarted;

- (NSArray*)validate;

@end

@implementation LoginViewController

#pragma mark - Lifecyle VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [super configureAllTapsWillDismissKeyboard];
    
    self.title = [@"Sign In" localized];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [self.btnLoginFacebook setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBGFacebook"]]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupDesign];
    
    self.emailTextField.isAccessibilityElement = YES;
    self.passwordTextField.isAccessibilityElement = YES;
    
    self.fbLoginProcessStarted = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.accessibilityIdentifier = self.title;
    [self.navigationController setNavigationBarHidden:NO];
    [self updateTextFieldBasedOnFBToken];
    if (self.fbLoginProcessStarted) {
        [self showHUD];
    }
}

- (void)setupDesign {
    [self.navigationController setNavigationBarHidden:NO];
    
    self.btnDone = [UIBarButtonItem defaultWithTitle:@"DONE" target:self action:@selector(doLogin:)];
    UIBarButtonItem *helpButton = [UIBarButtonItem blueImageName:@"Icon-need-help" target:self action:@selector(showSupportEmail:)];
    self.navigationItem.rightBarButtonItems = @[self.btnDone, helpButton];
    
    [self.emailTextField addLeftPadding:15.0];
    [self.passwordTextField addLeftPadding:15.0];
}

#pragma mark - IBActions

- (IBAction)doFacebook:(id)sender {
    __weak LoginViewController *weakSelf = self;
    
    [self showHUDForDuration:1.0];
    self.fbLoginProcessStarted = YES;

    [[RASessionManager sharedManager] loginWithFacebookFromViewController:self andCompletion:^(RAUserDataModel *user, NSError *error) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[RASessionManager sharedManager] needsToRegisterPhone] && (user != nil)) { //FBUser needs to register phone
            [defaults setBool:YES forKey:kFacebookSignin];
            [defaults synchronize];
            
            weakSelf.emailTextField.text = user.email;
            weakSelf.passwordTextField.text = user.password;
            [weakSelf updateTextFieldBasedOnFBToken];
            
            RegisterInfoViewController *rVC = [[RegisterInfoViewController alloc] init];
            rVC.fbUser = user;
            [weakSelf.navigationController pushViewController:rVC animated:YES];
        }
        else if (error){ // Error different from 202 occurred
            [ErrorReporter recordError:error withDomainName:FBLogin];
            [self showError:error.localizedRecoverySuggestion];
        }
        else if (!user){ // User cancelled
            //Nothing.
        }
        else { // FBUser is logged
            [defaults setBool:YES forKey:kFacebookSignin];
            [defaults synchronize];
            [weakSelf.delegate loginViewControllerDidLoginSuccessfully:weakSelf];
        }
        [weakSelf hideHUD];
        weakSelf.fbLoginProcessStarted = NO;
    }];
 }

- (void)doLogin:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    [self.view endEditing:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSArray* errors = [self validate];
    if (errors) {
        // check if last sign in used facebook

        NSError *err = [NSError errorWithDomain:@"com.rideaustin.error.login" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey : [errors objectAtIndex:0]}];
        [RAAlertManager showErrorWithAlertItem:err
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
        [errors.lastObject becomeFirstResponder];
        sender.enabled = YES;
    } else {
        [self showHUD];
        
        __weak LoginViewController *weakSelf = self;
        [[RASessionManager sharedManager] loginWithUsername:self.emailTextField.text password:self.passwordTextField.text andCompletion:^(RAUserDataModel *user, NSError *error) {
            [weakSelf hideHUD];
            if (error) {
                sender.enabled = YES;
                NSString *message = [error localizedRecoverySuggestion];
                // check if last sign in used facebook
                if ([defaults boolForKey:kFacebookSignin]) {
                    message = [message stringByAppendingString:[@". Did you mean to sign in using Facebook?" localized]];
                }
                message = [message stringByReplacingOccurrencesOfString:@"You are not authorized"
                                                             withString:[@"Sorry, your username or password is incorrect" localized]];
                
                [weakSelf showError:message];
            } else {
                [defaults setBool:NO forKey:kFacebookSignin];
                [weakSelf.delegate loginViewControllerDidLoginSuccessfully:weakSelf];
            }
        }];
    }
}

- (void)doForgotPassword:(id)sender {
    [self.delegate loginViewControllerDidTapForgotPassword:self];
}
     
#pragma mark - Validations

- (NSArray*)validate {
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField];
    } else {
        //FIX: RA-5062 - Fixed Email Validation to avoid test@test.com71~ or similar
        if(![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField];
        }
    }
    
    if([self.passwordTextField isEmpty]) {
        return @[[@"Please enter a password." localized], self.passwordTextField];
    } else {
        if([self.passwordTextField.text length]<kMinPasswordLength) {
            return @[ [NSString stringWithFormat:[@"Your password needs to be at least %li characters long." localized], (long)kMinPasswordLength], self.passwordTextField ];
        }
    }
    
    return nil;
}

- (void)showError:(NSString*)errorMessage {
    [RAAlertManager showErrorWithAlertItem:errorMessage andOptions:[RAAlertOption optionWithTitle:[@"SIGN IN FAILED" localized] withState:StateActive andShownOption:AllowNetworkError | Overlap]];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Textfield Helpers

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self doLogin:self.btnDone];
    }
    return YES;
}

- (void)updateTextFieldBasedOnFBToken {
    if ([FBSDKAccessToken currentAccessToken].tokenString != nil) {
        self.emailTextField.hidden    = YES;
        self.passwordTextField.hidden = YES;
    } else {
        self.emailTextField.text      = @"";
        self.passwordTextField.text   = @"";
        self.emailTextField.hidden    = NO;
        self.passwordTextField.hidden = NO;
    }
}

@end
