//
//  RegisterInfoViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/24/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "RegisterInfoViewController.h"
#import "ErrorReporter.h"
#import "LoginViewController.h"
#import "NSString+PhoneUtils.h"
#import "NSString+Utils.h"
#import "PinViewController.h"
#import "RACategories.h"
#import "RAEnvironmentManager.h"
#import "RAMacros.h"
#import "RAPhoneVerificationAPI.h"
#import "RAUserAPI.h"
#import "UITextField+Helpers.h"
#import "UIBarButtonItem+RAFactory.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MRCountryPicker/MRCountryPicker-Swift.h>

@interface RegisterInfoViewController ()<MRCountryPickerDelegate, PhoneVerificationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (nonatomic) UIEdgeInsets previousScrollInsets;
@property (nonatomic) UIEdgeInsets previousScrollIndicatorInsets;

// view to show when user sucessfully registers using Facebook
@property (weak, nonatomic) IBOutlet UIView *facebookRegisterContainerView;
// mobile phone input required when facebook account missing mobile phone
@property (weak, nonatomic) IBOutlet UITextField *mobileTextFieldFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *imgFlag2;
@property (nonatomic) BOOL isRegisteringByFacebook;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imgFlag;

@property (strong, nonatomic) IBOutlet UIView *viewCountryPicker;
@property (weak, nonatomic) IBOutlet MRCountryPicker *countryPicker;
@property (nonatomic) NSString *countryCode;


@end

@implementation RegisterInfoViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Create Account" localized];
    
    if([[RASessionManager sharedManager] needsToRegisterPhone]){
        RAUserDataModel *fbUser = self.fbUser;
        self.emailTextField.text = fbUser.email;
        self.passwordTextField.text = fbUser.password;
        self.isRegisteringByFacebook = YES;
        self.facebookRegisterContainerView.hidden = NO;
    }
    else{ //This was causing that fb token is lost
        if([FBSDKAccessToken currentAccessToken] != nil) {
            FBSDKLoginManager *logMeOut = [[FBSDKLoginManager alloc] init];
            [logMeOut logOut];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.countryPicker setCountryPickerDelegate:self];
    
    self.emailTextField.isAccessibilityElement = YES;
    self.mobileTextField.isAccessibilityElement = YES;
    self.mobileTextFieldFacebook.isAccessibilityElement = YES;
    self.passwordTextField.isAccessibilityElement = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.accessibilityIdentifier = self.title;
    [self setupDesign];
    
    UIBarButtonItem *nextButton = [UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(doNext:)];
    UIBarButtonItem *helpButton = [UIBarButtonItem blueImageName:@"Icon-need-help" target:self action:@selector(showSupportEmail:)];
    self.navigationItem.rightBarButtonItems = @[nextButton, helpButton];
}

- (void)setupDesign {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController setNavigationBarHidden:NO];
    [self.emailTextField becomeFirstResponder];
    
    [self.btnFacebook setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBGFacebook"]]];
    
    //Add Paddings to fields
    [self.emailTextField addLeftPadding:10.0];
    [self.mobileTextField addLeftPadding:10.0];
    [self.passwordTextField addLeftPadding:10.0];
    
    //Setup Country Picker
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    [self.countryPicker setCountry:countryCode];
    [self.imgFlag.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imgFlag.layer setBorderWidth:1.0];
    [self.imgFlag2.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imgFlag2.layer setBorderWidth:1.0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction

- (IBAction)btnSelectCountryPressed:(UIButton *)sender {
    KLCPopup *popupCountryPicker =
    [KLCPopup popupWithContentView:self.viewCountryPicker
                          showType:KLCPopupShowTypeBounceIn
                       dismissType:KLCPopupDismissTypeBounceOut
                          maskType:KLCPopupMaskTypeDimmed
          dismissOnBackgroundTouch:YES
             dismissOnContentTouch:NO];
    [popupCountryPicker show];
}

- (IBAction)doFacebook:(id)sender {
    
    __weak RegisterInfoViewController *weakSelf = self;
    
    [[RASessionManager sharedManager] loginWithFacebookFromViewController:self andCompletion:^(RAUserDataModel *user, NSError *error) {
        [weakSelf hideHUD];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[RASessionManager sharedManager] needsToRegisterPhone] && (user != nil)) { //FBUser needs to register phone
            [defaults setBool:YES forKey:kFacebookSignin];
            [defaults synchronize];
            
            weakSelf.emailTextField.text = user.email;
            weakSelf.passwordTextField.text = user.password;
            
            // Need to show phone field only, so show the container view (RA-219)
            weakSelf.facebookRegisterContainerView.hidden = NO;
            weakSelf.isRegisteringByFacebook = YES;
        }
        else if (error){ // Error different from 202 occurred
            weakSelf.isRegisteringByFacebook = NO;
            [ErrorReporter recordError:error withDomainName:FBLogin];
            [self showError:error];
        }
        else if (!user){ // User cancelled
            weakSelf.isRegisteringByFacebook = NO;
        }
        else{ // FBUser is logged
            [defaults setBool:YES forKey:kFacebookSignin];
            [defaults synchronize];
            [weakSelf.delegate registerInfoViewControllerDidRegisterSuccessfullyWithFacebook:weakSelf];
        }
    }];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)doNext:(id)sender {
    
   [self.view endEditing:YES];

    NSArray* errors = [self validate];
    if (errors) {
        NSString *failureValidationReason = [errors objectAtIndex:0];
        [RAAlertManager showErrorWithAlertItem:failureValidationReason andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError | Overlap]];
        [[errors lastObject] becomeFirstResponder];
    } else {
        if (self.isRegisteringByFacebook) {
            [self proceed];
        } else {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:[@"Please confirm your email address" localized] message:self.emailTextField.text preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:[@"Correct" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self proceed];
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[@"Re-enter" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.emailTextField becomeFirstResponder];
            }];
            [ac addAction:actionOK];
            [ac addAction:actionCancel];
            [self presentViewController:ac animated:YES completion:nil];
        }
    }
}

- (void)proceed {
    [self showHUD];
    
    __weak RegisterInfoViewController *weakSelf = self;
    [RAUserAPI checkAvailabilityOfEmail:self.emailTextField.text andPhone:[self activePhoneNumber] withCompletion:^(BOOL failed, NSError *error) {
        [weakSelf hideHUD];
        if (failed) {
            NSString *failureReason = error.localizedRecoverySuggestion ? error.localizedRecoverySuggestion : error.localizedDescription;
            
            if (error.code == 400) {
                failureReason = [failureReason stringByReplacingOccurrencesOfString:@"Username" withString:@"Email" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [failureReason length])];
                [weakSelf showErrorMessage:failureReason];
            } else {
                [weakSelf showError:error];
            }
        } else {
            [weakSelf doSMSVerification];
        }
    }];
}

#pragma mark - Private

- (void)showError:(NSError*)error {
    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError | Overlap]];
}

- (NSArray*)validate {
    //
    //  if the user registered using facebook, we just need to check the phone number
    //
    if (self.isRegisteringByFacebook) {
        // FIX: RA-7588 - Phone Number Validation with 15 digits max length
        // https://en.wikipedia.org/wiki/E.164
        if(![self.mobileTextFieldFacebook isValidPhone]) {
            return @[[@"Please enter a valid mobile phone number. i.e Minimum 8 digits and Max 15 digits" localized], self.mobileTextFieldFacebook ];
        }
        // else
        return nil;
    }
    
    //
    // else
    //
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField ];
    } else {
        //FIX: RA-5062 - Fixed Email Validation to avoid test@test.com71~ or similar
        if(![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField ];
        }
    }
    
    if([self.mobileTextField isEmpty]) {
        return @[[@"Please enter your mobile phone number." localized], self.mobileTextField ];
    } else {
        // FIX: RA-7588 - Phone Number Validation with 15 digits max length
        // https://en.wikipedia.org/wiki/E.164
        if(![self.mobileTextField isValidPhone]) {
            return @[[@"Please enter a valid mobile phone number. i.e Minimum 8 digits and Max 15 digits" localized], self.mobileTextField ];
        }
    }
    
    if([self.passwordTextField isEmpty]) {
        return @[[@"Please enter a password." localized], self.passwordTextField ];
    } else if (self.passwordTextField.text.length < kMinPasswordLength) {
        NSString *msg = [NSString stringWithFormat:[@"Your password needs to be at least %li characters long." localized], (long)kMinPasswordLength];
        return @[msg, self.passwordTextField];
    }
    
    return nil;
}

- (void)doSMSVerification {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TEST MODE"
                                                                   message:@"Do you want to bypass the pin verification?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Phone number was successfully verified
        [self phoneVerificationDidSucceed];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doVerification];
    }];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    
    if (![RAEnvironmentManager sharedManager].isProdServer) {
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    } else {
        [self doVerification];
    }
}

- (void)doVerification {
    NSString *phoneNumber  = self.activePhoneNumber;
    [RAPhoneVerificationAPI postVerifyPhoneNumber:phoneNumber withCompletion:^(NSString *token, NSError *error) {
        if (token) {
            [self hideHUD];
            PinViewController *pVC = [[PinViewController alloc] initWithToken:token
                                                                       mobile:phoneNumber
                                                                     delegate:self];
            [self.navigationController pushViewController:pVC animated:YES];
        } else {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setBackground:[UIImage imageNamed:@"Field-active"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setBackground:[UIImage imageNamed:@"Field"]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    if (textField == self.mobileTextField || textField == self.mobileTextFieldFacebook) {
        NSString *updatedPhone = [textField.text stringByReplacingCharactersInRange:range withString:string];
        shouldChange = [updatedPhone hasCountryCode:self.countryCode];
    }
    
    if (shouldChange && [string isEqualToString:@""]) {
        return YES;
    }
    
    return shouldChange && [textField.text length] <= kTextFieldMaxLength;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.text = textField.text.trim;
    if(textField == self.emailTextField) {
        [self.mobileTextField becomeFirstResponder];
    } else if(textField == self.mobileTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.mobileTextFieldFacebook) {
        [self doNext:nil];
    } else if(textField == self.passwordTextField) {
        [self doNext:nil];
    }
    return YES;
}

#pragma mark - Handle Keyboard notifications

- (void)keyboardDidShow:(NSNotification*)notification {
    self.previousScrollIndicatorInsets = self.scrollViewContainer.scrollIndicatorInsets;
    self.previousScrollInsets = self.scrollViewContainer.contentInset;
    
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect scrollViewFrame = [self.scrollViewContainer convertRect:keyboardFrame fromView:nil];
    self.scrollViewContainer.contentInset = UIEdgeInsetsMake(0, 0, scrollViewFrame.size.height, 0);
    self.scrollViewContainer.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, scrollViewFrame.size.height, 0);
    
    self.scrollViewContainer.contentSize = CGSizeMake(self.scrollViewContainer.bounds.size.width, 350);
}

- (void)keyboardDidHide:(NSNotification*)notification {
    self.scrollViewContainer.contentInset = self.previousScrollInsets;
    self.scrollViewContainer.scrollIndicatorInsets = self.previousScrollIndicatorInsets;
    self.scrollViewContainer.contentOffset = CGPointMake(0, 0);
}

#pragma mark - Error Handling

- (void) showErrorMessage:(NSString*)errorMsg {
    [self hideHUD];
    
    UIAlertAction *signinAction = [UIAlertAction actionWithTitle:[@"Login" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_queue_create("creator", NULL), ^{
            LoginViewController *login= [[LoginViewController alloc] init];
            NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
            [vcs addObject:login];
            [vcs removeObject:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController setViewControllers:vcs animated:YES];
            });
        });
    }];
    
    NSString *errLow = [errorMsg lowercaseString];
    BOOL emailAvailable = ![errLow containsString:@"email"];
    BOOL phoneNumberAvailable = ![errLow containsString:@"phone"];
    UIAlertAction *signupAction = [UIAlertAction actionWithTitle:[@"Edit" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
     
        if (!emailAvailable) {
            [self.emailTextField becomeFirstResponder];
        }
        else if (!phoneNumberAvailable) {
            [self.mobileTextField becomeFirstResponder];
        }
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[@"GENERIC_ERROR_TITLE" localized] message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:signinAction];
    [alert addAction:signupAction];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark- Country Picker Delegate

- (void)countryPhoneCodePicker:(MRCountryPicker *)picker didSelectCountryWithName:(NSString *)name countryCode:(NSString *)countryCode phoneCode:(NSString *)phoneCode flag:(UIImage *)flag {

    [self.imgFlag setImage:flag];
    [self.imgFlag2 setImage:flag];
    [self.mobileTextField setText:phoneCode];
    [self.mobileTextFieldFacebook setText:phoneCode];
    self.countryCode = phoneCode;
}

#pragma mark - PhoneVerificationDelegate

- (void)phoneVerificationDidSucceed {
    NSString *email         = self.emailTextField.text;
    NSString *phoneNumber   = self.activePhoneNumber;
    NSString *password      = self.passwordTextField.text;
    
    // Check if we are logged in with facebook
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token) {
        FBSDKGraphRequest *gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,email,first_name,last_name"}];
        [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (error) {
                [ErrorReporter recordError:error withDomainName:FBGraph];
                return;
            }
            NSString *firstName  = result[@"first_name"];
            NSString *lastName   = result[@"last_name"];
            NSString *facebookId = result[@"id"];
            RAUserDataModel *user = [RAUserDataModel new];
            user.email = result[@"email"] ?: email;
            user.firstname = firstName;
            user.lastname = lastName;
            user.phoneNumber = phoneNumber;
            user.facebookID = facebookId;
            user.password = token.tokenString;
            __weak RegisterInfoViewController *weakSelf = self;
            [[RASessionManager sharedManager] registerUser:user withCompletion:^(RAUserDataModel *user, NSError *error) {
                [weakSelf hideHUD];
                
                if (!error) {
                    [weakSelf.delegate registerInfoViewControllerDidRegisterSuccessfullyWithFacebook:weakSelf];
                } else {
                    [RAAlertManager showErrorWithAlertItem:error
                                                andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                }
            }];
         }];
    } else {
        [self hideHUD];
        [self.delegate registerInfoViewControllerDidVerify:phoneNumber
                                                     email:email
                                                  password:password];
    }
}

- (NSString *)activePhoneNumber {
    if (self.isRegisteringByFacebook) {
        return self.mobileTextFieldFacebook.text;
    } else {
        return self.mobileTextField.text;
    }
}

@end
