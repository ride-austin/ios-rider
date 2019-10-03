//
//  LoginViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@class LoginViewController;
@protocol LoginViewControllerDelegate
- (void)loginViewControllerDidLoginSuccessfully:(LoginViewController *)loginViewController;
- (void)loginViewControllerDidTapForgotPassword:(LoginViewController *)loginViewController;
@end

@class PaddedTextField;

@interface LoginViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@property(nonatomic, strong) IBOutlet PaddedTextField* emailTextField;
@property(nonatomic, strong) IBOutlet PaddedTextField* passwordTextField;
@property(nonatomic, strong) IBOutlet UIButton* loginButton;

- (IBAction)doFacebook:(id)sender;
- (IBAction)doForgotPassword:(id)sender;

@end
