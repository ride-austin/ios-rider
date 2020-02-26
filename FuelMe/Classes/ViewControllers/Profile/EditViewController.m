//
//  EditViewController.h.m
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "EditViewController.h"

#import "ErrorReporter.h"
#import "GenderViewController.h"
#import "NSString+PhoneUtils.h"
#import "NSString+Utils.h"
#import "NSString+Valid.h"
#import "PaddedTextField.h"
#import "PasswordViewController.h"
#import "PinViewController.h"
#import "RAEmailVerificationPopup.h"
#import "RAEnvironmentManager.h"
#import "RAPhoneVerificationAPI.h"
#import "RAUserAPI.h"
#import "UIImage+Ride.h"
#import "UITextField+Helpers.h"
#import "UITextField+Valid.h"
#import "RAAlertManager.h"

#import "SVProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MRCountryPicker/MRCountryPicker-Swift.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *const kScreenTitle = @"Edit Account";
static NSInteger const kMinimumFirstAndLastNameLength = 2;

@interface EditViewController ()

//Properties
@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic) UIEdgeInsets previousScrollInsets;
@property (nonatomic) UIEdgeInsets previousScrollIndicatorInsets;
@property (strong, nonatomic)NSString * countryCode;
@property (nonatomic) BOOL changePhoneText;
@property (nonatomic) RAEmailVerificationPopup *emailVerificationPopup;

//IBOutlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgFlag;
@property (weak, nonatomic) IBOutlet MRCountryPicker *countryPicker;
@property (strong, nonatomic) IBOutlet UIView *viewCountryPicker;

@property (weak, nonatomic) IBOutlet UIButton *firstNameButton;
@property (weak, nonatomic) IBOutlet UIButton *lastNameButton;

@property (weak, nonatomic) IBOutlet UIButton *emailButtonOverlay;
@property (weak, nonatomic) IBOutlet PaddedTextField* firstNameTextField;
@property (weak, nonatomic) IBOutlet PaddedTextField* lastNameTextField;
@property (weak, nonatomic) IBOutlet PaddedTextField* emailTextField;
@property (weak, nonatomic) IBOutlet PaddedTextField* mobileTextField;
@property (weak, nonatomic) IBOutlet PaddedTextField* passwordTextField;
@property (weak, nonatomic) IBOutlet PaddedTextField *genderTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ivActivityIndicatorView;

@end

@interface EditViewController (TextFields) <UITextFieldDelegate>

- (void)configureTextFieldObservers;

@end

@interface EditViewController (CountryPickerDelegate) <MRCountryPickerDelegate>
@end

@interface EditViewController (PhoneverificationDelegate) <PhoneVerificationDelegate>
@end

@interface EditViewController (Private)

- (void)verifyFlagForPhoneNumber:(NSString*)phoneNumber;
- (void)showAlertUnrecognizedCountryCode:(NSString *)phoneNumber;
- (void)showAlertToContactSupportFor:(NSString *)targetField sender:(UIButton*)sender;
- (void)setMobileTextfieldEnabled;

@end

@implementation EditViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.changePhoneText = YES;
    [self addObservers];

    //Configure UI
    [self configureNavigationBar];
    [self configureTextFields];
    [self configureTextFieldObservers];
    [self configureCountryPicker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserProfile];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureNavigationBar {
    self.title = kScreenTitle;
    self.navigationController.navigationBar.accessibilityIdentifier = kScreenTitle;
    
    [self.navigationController setNavigationBarHidden:NO];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(attemptToSaveChanges)];
    
    [self.navigationItem setRightBarButtonItem:self.saveButton];
    [self toggleSaveButton:NO];
}

- (void)configureTextFields {
    ConfigGenderSelection *config = [ConfigurationManager shared].global.genderSelection;
    self.genderTextField.placeholder = config.title;
    self.genderTextField.enabled = NO;
    self.emailTextField.enabled = NO;
    self.emailTextField.textColor = UIColor.placeholderColor;
    [self.genderTextField addLeftPadding:15.0];
    [self.emailTextField addLeftPadding:15.0];
    [self.mobileTextField addLeftPadding:15.0];
    [self.lastNameTextField addLeftPadding:15.0];
    [self.passwordTextField addLeftPadding:15.0];
    [self.firstNameTextField addLeftPadding:15.0];
}

- (void)configureCountryPicker {
    [self.countryPicker setCountryPickerDelegate:self];
    [self.imgFlag.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.imgFlag.layer setBorderWidth:1.0];
}

- (void)updateUserProfile {
    __weak __typeof__(self) weakself = self;
    
    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    
    self.firstNameTextField.text = user.firstname;
    self.lastNameTextField.text  = user.lastname;
    self.emailTextField.text     = user.email;
    self.mobileTextField.text    = user.phoneNumber;
    self.passwordTextField.text  = @"BOGUS SHIT";
    self.genderTextField.text = [user.gender isEqualToString:@"UNKNOWN"] ? nil : user.gender;
    
    //Setup photo profile
    [self.ivActivityIndicatorView startAnimating];
    [self.userImageView sd_setImageWithURL:user.photoURL placeholderImage:[UIImage imageNamed:@"person_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakself.ivActivityIndicatorView stopAnimating];
    }];
    
    #warning Email Validation Disabled
    //Configure Email Verification
    // TODO: Check email verification status
    //UIImage *emailVerificationIcon = [UIImage imageNamed: 1 == 0 ? @"email-verified-field-icon" : @"email-unverified-field-icon"];
    //[self.emailButtonOverlay setImage:emailVerificationIcon forState:UIControlStateNormal];
    
    NSString *phone = [user.phoneNumber clearedPhoneNumber];
    if (phone) {
        [self verifyFlagForPhoneNumber:phone];
        if (phone.countryCode == nil) {
            [self showAlertUnrecognizedCountryCode:phone];
            [self.countryPicker setCountry:@"US"];
            self.mobileTextField.text = self.countryCode;
        }
    } else {
        [self.countryPicker setCountry:@"US"];
    }
    
    [self setMobileTextfieldEnabled];
    [self updateDriverRestrictions:user.isDriver];
}

- (void)updateDriverRestrictions:(BOOL)isDriver {
    self.firstNameButton.hidden = !isDriver;
    self.lastNameButton.hidden = !isDriver;
    self.firstNameTextField.enabled = !isDriver;
    self.lastNameTextField.enabled = !isDriver;
    
    self.firstNameTextField.textColor = isDriver ? UIColor.placeholderColor : UIColor.charcoalGrey;
    self.lastNameTextField.textColor = isDriver ? UIColor.placeholderColor : UIColor.charcoalGrey;
}

- (void)toggleSaveButton:(BOOL)enabled {
    //Enable/Disable save button
    self.saveButton.enabled = enabled;
}

#pragma mark - Observers

- (void)addObservers {
    __weak EditViewController *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        weakSelf.previousScrollIndicatorInsets = weakSelf.scrollViewContainer.scrollIndicatorInsets;
        weakSelf.previousScrollInsets = weakSelf.scrollViewContainer.contentInset;
        
        CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect scrollViewFrame = [weakSelf.scrollViewContainer convertRect:keyboardFrame fromView:nil];
        weakSelf.scrollViewContainer.contentInset = UIEdgeInsetsMake(0, 0, scrollViewFrame.size.height, 0);
        weakSelf.scrollViewContainer.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, scrollViewFrame.size.height, 0);
        
        CGFloat marginBottom = 15;
        CGFloat heightSize = weakSelf.mobileTextField.frame.origin.y + weakSelf.mobileTextField.bounds.size.height + marginBottom;
        
        weakSelf.scrollViewContainer.contentSize = CGSizeMake(weakSelf.scrollViewContainer.bounds.size.width, heightSize);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        weakSelf.scrollViewContainer.contentInset = self.previousScrollInsets;
        weakSelf.scrollViewContainer.scrollIndicatorInsets = self.previousScrollIndicatorInsets;
        weakSelf.scrollViewContainer.contentOffset = CGPointMake(0, 0);
    }];
}

#pragma mark - IBActions

- (IBAction)changePhoto:(id)sender {
    [self.view endEditing:YES];
    __weak EditViewController *weakSelf = self;
    
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.picturePickerManager showPickerControllerFromViewController:weakSelf sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            return;
        }
        
        //Resize Image
        CGFloat maxArea = 480000;
        image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
        
        [weakSelf showHUD];
        [[RASessionManager sharedManager] updateUserPhoto:image withCompletion:^(RAUserDataModel *user, NSError *error) {
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                return;
            }
            
            [SVProgressHUD dismissWithCompletion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.userImageView setImage:image];
                    [weakSelf showSuccessHUDWithDismissDelay:0];
                });
            }];
        }];
    }];
}

- (IBAction)didTapFirstName:(UIButton*)sender {
    [self showAlertToContactSupportFor:@"first name" sender:sender];
}

- (IBAction)didTapLastName:(UIButton*)sender {
    [self showAlertToContactSupportFor:@"last name" sender:sender];
}

- (IBAction)didTapEmail:(UIButton*)sender {
    [self showAlertToContactSupportFor:@"email" sender:sender];
    //TODO: Show popup based on status of User Model
    //self.emailVerificationPopup = [RAEmailVerificationPopup popupWithEmail:@"sample@gmail.com" delegate:nil showingState:EmailUnverifiedStatus];
    //[self.emailVerificationPopup show];
}

- (IBAction)changePassword:(id)sender; {
    PasswordViewController *pVC = [[PasswordViewController alloc] init];
    [self.navigationController pushViewController:pVC animated:YES];
}

- (IBAction)didTapGender {
    [self dismissKeyboard];
    
    __weak __typeof__(self) weakself = self;
    
    ConfigGlobal *global = [ConfigurationManager shared].global;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    GenderViewController *vc = [storyboard instantiateViewControllerWithIdentifier:GenderViewController.className];
    vc.viewModel = [GenderViewModel viewModelWithConfig:global andDidSaveGenderHandler:^(RAUserDataModel *user) {
        [weakself.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnSelectCountryPressed:(UIButton *)sender {
    [self dismissKeyboard];
    
    KLCPopup *popupCountryPicker = [KLCPopup popupWithContentView:self.viewCountryPicker
                                                         showType:KLCPopupShowTypeBounceIn
                                                      dismissType:KLCPopupDismissTypeBounceOut
                                                         maskType:KLCPopupMaskTypeDimmed
                                         dismissOnBackgroundTouch:YES
                                            dismissOnContentTouch:NO];
    [popupCountryPicker show];
}

- (void)attemptToSaveChanges {
    [self.view endEditing:NO];
    if ([self isProfileFormValid]) {
        [self saveUser];
    }
}

- (void)saveUser {
    
    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    NSString *newPhone = self.mobileTextField.text;
    BOOL needsVerification = [newPhone isEqualToString:user.phoneNumber] == NO;
    
    if (needsVerification) {
        __weak EditViewController *weakSelf = self;
        [RAUserAPI checkAvailabilityOfPhone:newPhone withCompletion:^(BOOL failed, NSError *error) {
            if (failed) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            } else {
                if (![[RAEnvironmentManager sharedManager] isProdServer]) {
                    
                    RAAlertOption *alertOptions = [RAAlertOption optionWithState:StateActive];
                    [alertOptions addAction:[RAAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                        [weakSelf submitSaveRequest];
                    }]];
                    
                    [alertOptions addAction:[RAAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                        [weakSelf verifyPhoneNumber:newPhone];
                    }]];
                    
                    [RAAlertManager showAlertWithTitle:@"TEST MODE" message:@"Do you want to bypass the pin verification?" options:alertOptions];
                } else {
                    [weakSelf verifyPhoneNumber:newPhone];
                }
            }
        }];
    } else {
        [self submitSaveRequest];
    }
}

- (void)submitSaveRequest {
    NSString *email = self.emailTextField.text;
    NSString *firstname = self.firstNameTextField.text;
    NSString *lastname = self.lastNameTextField.text;
    NSString *phone = self.mobileTextField.text;
    
    [self showHUD];
    __weak EditViewController *weakSelf = self;
    [[RASessionManager sharedManager] updateUserEmail:email firstname:firstname lastname:lastname phoneNumber:phone withCompletion:^(RAUserDataModel *user, NSError *error) {
        if (!error) {
            [SVProgressHUD dismissWithCompletion:^{
                [weakSelf showSuccessHUDWithDismissDelay:1];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        } else{
            [weakSelf hideHUD];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        }
    }];
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber {
    [self showHUD];
    __weak EditViewController *weakSelf = self;
    [RAPhoneVerificationAPI postVerifyPhoneNumber:phoneNumber withCompletion:^(NSString *token, NSError *error) {
        [weakSelf hideHUD];
        if (token) {
            PinViewController *pVC = [[PinViewController alloc] initWithToken:token mobile:phoneNumber delegate:weakSelf];
            [weakSelf.navigationController pushViewController:pVC animated:YES];
        } else {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        }
    }];
}

#pragma mark - Validations

- (BOOL)isProfileFormValid {
    
    //Emails validations
    if ([self.emailTextField isEmpty]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter your email address." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.emailTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self.emailTextField isValidEmail]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid email address." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.emailTextField becomeFirstResponder];
        return NO;
    }
    
    //Firstname validations
    if (self.firstNameTextField.text.trim.length < kMinimumFirstAndLastNameLength) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid first name with minimum two letters." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.firstNameTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self.firstNameTextField isValidEnglishName]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid first name with english letters only." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.firstNameTextField becomeFirstResponder];
        return NO;
    }
    
    //Lastname Validations
    if (self.lastNameTextField.text.trim.length < kMinimumFirstAndLastNameLength) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid last name with minimum two letters." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.lastNameTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self.lastNameTextField isValidEnglishName]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid last name with english letters only." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.lastNameTextField becomeFirstResponder];
        return NO;
    }
    
    //Phone number validations
    if ([self.mobileTextField isEmpty]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter your phone number." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.mobileTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self.mobileTextField.text isValidPhoneNumberLength]) {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter a valid mobile phone number. i.e Minimum 8 digits." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        [self.mobileTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateAnyChange {
    BOOL changed = NO;

    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    
    if (![user.firstname isEqualToString:self.firstNameTextField.text]) {
        changed = YES;
    }

    if (![user.lastname isEqualToString:self.lastNameTextField.text]) {
        changed = YES;
    }

    if (![user.email isEqualToString:self.emailTextField.text]) {
        changed = YES;
    }

    if (![user.phoneNumber isEqualToString:self.mobileTextField.text] && [self.mobileTextField.text isValidPhone] && [self.mobileTextField.text isValidPhoneNumberLength]) {
        changed = YES;
    }
    
    if ([self.countryCode isEqualToString:self.mobileTextField.text]) {
        return NO;
    }
    
    if ([self.firstNameTextField.text length] < kMinimumFirstAndLastNameLength || [self.lastNameTextField.text length] < kMinimumFirstAndLastNameLength) {
        changed = NO;
    }
    
    return changed;
}

@end

#pragma mark - Country Picker Delegate

@implementation EditViewController (CountryPickerDelegate)

- (void)countryPhoneCodePicker:(MRCountryPicker *)picker didSelectCountryWithName:(NSString *)name countryCode:(NSString *)countryCode phoneCode:(NSString *)phoneCode flag:(UIImage *)flag{
    [self.imgFlag setImage:flag];
    if (self.changePhoneText) {
        [self.mobileTextField setText:phoneCode];
        [self setMobileTextfieldEnabled];
    } else {
        self.changePhoneText = YES;
    }
    self.countryCode = phoneCode;
}

@end

#pragma mark - Phone Verification Delegate

@implementation EditViewController (PhoneverificationDelegate)

- (void)phoneVerificationDidSucceed {
    [self.navigationController popViewControllerAnimated:YES];
    [self submitSaveRequest];
}

@end

#pragma mark - TextFields

@implementation EditViewController (TextFields)

- (void)configureTextFieldObservers {
    [self.firstNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.lastNameTextField  addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.emailTextField     addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.mobileTextField    addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange :(UITextField *)textField {
    BOOL changed = [self validateAnyChange];
    [self toggleSaveButton:changed];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.mobileTextField) {
        if (textField.text.length == 0) {
            [self.countryPicker setCountryByPhoneCode:self.countryCode];
        } else {
            [self verifyFlagForPhoneNumber:self.mobileTextField.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.mobileTextField becomeFirstResponder];
    } else if (textField == self.mobileTextField) {
        [self attemptToSaveChanges];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if (textField == self.mobileTextField ) {
        //Restricting the country code deletion
        NSString *updatedPhone = [textField.text stringByReplacingCharactersInRange:range withString:string];
        shouldChange = [updatedPhone hasCountryCode:self.countryCode];
    }
    return shouldChange;
}

@end

#pragma mark - Private

@implementation EditViewController (Private)

- (void)verifyFlagForPhoneNumber:(NSString *)phoneNumber{
    NSString *countryCode = [phoneNumber countryCode];
    self.changePhoneText = NO;
    if (countryCode) {
        [self.countryPicker setCountryByPhoneCode:countryCode];
    }
}

- (void)showAlertUnrecognizedCountryCode:(NSString *)phoneNumber {
    NSString *message = [NSString stringWithFormat:[@"We cannot recognize the country code of %@. Please update your phone number." localized], phoneNumber];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName]
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[@"OK" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.mobileTextField.text = self.countryCode;
        [self.mobileTextField becomeFirstResponder];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertToContactSupportFor:(NSString *)targetField sender:(UIButton*)sender {
    NSString *title = [NSString stringWithFormat:@"You need to contact support to change your %@", targetField];
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alert.popoverPresentationController.sourceView = sender;
    alert.popoverPresentationController.sourceRect = sender.bounds;
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Contact support" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showMessageViewWithRideID:nil cityID:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setMobileTextfieldEnabled {
    BOOL enabled = YES;
    UIImage *bg = enabled ? [UIImage imageNamed:@"Field"] : [UIImage imageNamed:@"Field-unactive"];
    self.mobileTextField.background = bg;
    self.mobileTextField.enabled = enabled;
}

@end



