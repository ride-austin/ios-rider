//
//  DriverFCRARightsViewController.m
//  Ride
//
//  Created by Carl von Havighorst on 7/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverFCRARightsViewController.h"
#import "NSString+Utils.h"
#import "NSString+Valid.h"
#import "RAMacros.h"
#import "Ride-Swift.h"
#import "UITextField+Helpers.h"
#define kFirstSlashIndexToAdd       3
#define kSecondSlashIndexToAdd      6
#define kSSNLength                  11 //Including dash (###-##-####)
#define kFirstNameMinimumLength     2
#define kMiddleNameMinimumLength    2
#define kLastNameMinimumLength      2
#define kDriverLicenseMinimumLength 7
#define kDriverLicenseMaximum       8
#define kStateCodeLength            2
#define kAddressMinimumLength       2

@interface DriverFCRARightsViewController() <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *dobPicker;
@property (strong, nonatomic) IBOutlet UIView *viewDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;

@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtMiddleName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentZip;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtSSN;
@property (weak, nonatomic) IBOutlet UITextField *txtDL;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UIButton *imgMiddleNameCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *imgAckCheckBox;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *lblInformationLawTitle;
@property (nonatomic,assign)BOOL checkMiddleName;
@property (nonatomic,assign)BOOL checkAck;
@property (weak, nonatomic) UITextField *activeField;
@property (strong, nonatomic) KLCPopup * popupDOB;
@property (nonatomic) NSDate *dateOfBirth;

@end

@implementation DriverFCRARightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatePickerPopup];
    
    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    if (user) {
        self.txtFirstName.text = user.firstname;
        self.txtLastName.text = user.lastname;
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    
    [self.view addGestureRecognizer:singleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    [self.scrollView setCanCancelContentTouches:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [self configureDatePicker];
    self.navigationController.navigationBarHidden = NO;
    self.txtSSN.secureTextEntry = NO;
    
    self.lblInformationLawTitle.text = [self.lblInformationLawTitle.text stringByReplacingOccurrencesOfString:@"RideAustin" withString:super.regConfig.appName];
}

- (void)configureDatePicker {
    NSDate *now = [NSDate date];
    NSDateComponents *minus70Years = [NSDateComponents new];
    NSDateComponents *minus21Years = [NSDateComponents new];
    minus70Years.year = -70;
    minus21Years.year = -21;
    NSDate *seventyYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:minus70Years toDate:now options:0];
    NSDate *twentyOneYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:minus21Years toDate:now options:0];
    [self.dobPicker setDate:twentyOneYearsAgo];
    self.dobPicker.minimumDate = seventyYearsAgo;
    self.dobPicker.maximumDate = twentyOneYearsAgo;
}

- (void)dismissKeyBoard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];

    self.title = [@"FCRA Disclosure" localized];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    
    self.checkMiddleName = NO;
    self.checkAck = NO;
    NSString *capturedSSN = self.coordinator.driver.ssn;
    if (capturedSSN) {
        [self.txtSSN setText:capturedSSN];
    }
    [self addEdgeInsetsToTextFields];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didTapNext {

    NSString *firstName = [NSString stringWithString: self.txtFirstName.text];
    NSString *lastName = [NSString stringWithString: self.txtLastName.text];
    NSString *middleName = [NSString stringWithString: self.txtMiddleName.text];
    NSString *currentZip = [NSString stringWithString: self.txtCurrentZip.text];
    NSString *driverLicenceNum = [[NSString stringWithString: self.txtDL.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.txtState.text = [self.txtState.text uppercaseString];
    NSString *stateCode = [NSString stringWithString: self.txtState.text];
    NSString *ssn = [NSString stringWithString: self.txtSSN.text];
    BOOL confirmedNoMiddleName = self.imgMiddleNameCheckBox.isSelected;
    NSString *address = [NSString stringWithString: self.txtAddress.text];
    
    if (firstName.length < kFirstNameMinimumLength ) {
        NSString *message = [NSString stringWithFormat:[@"First name must be at least %i characters" localized], kFirstNameMinimumLength];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    } else if (!firstName.isValidEnglishName) {
        NSString *message = [@"Please enter a valid first name with english letters only." localized];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (!confirmedNoMiddleName && middleName.length < kMiddleNameMinimumLength) {
        NSString *message = [NSString stringWithFormat: [@"Middle name must be at least %i characters or confirm you do not have a middle name" localized], kLastNameMinimumLength];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    } else if (!confirmedNoMiddleName && middleName.length == 0) {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please confirm you do not have a middle name" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        
        return;
    } else if (!confirmedNoMiddleName && !middleName.isValidEnglishName) {
        NSString *message = [@"Please enter a valid middle name with english letters only." localized];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }

    
    if (lastName.length < kLastNameMinimumLength ) {
        NSString *message = [NSString stringWithFormat:[@"Last name must be at least %i characters" localized], kLastNameMinimumLength];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    } else if (!lastName.isValidEnglishName) {
        NSString *message = [@"Please enter a valid last name with english letters only." localized];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (self.dateOfBirth == nil) {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please enter a valid Birth Date (MM/DD/YYYY)" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (ssn.length < kSSNLength) {
        [RAAlertManager showAlertWithTitle:@""
                                   message:[@"Please enter valid SSN number i.e 9 digits number" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    //FIX RA-4300 - Validate Zip Non Empty 
    if (!IS_EMPTY(currentZip) && [currentZip rangeOfString: @"^\\d{5}(?:[-\\s]\\d{4})?$" options:NSRegularExpressionSearch].location != NSNotFound) {
        // zipCode conforms to 78746 or 78746-1234 or 78746 1234 format
    } else {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please enter a valid Zip code" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    // DRIVER LICENSE NUMBER FORMAT
    // https://www.dps.texas.gov/DriverLicense/DLSearch/DLStatus.aspx
    // Based on this https://ntsi.com/drivers-license-format/
    // Texas 7-8Numeric
    BOOL isDriverLicenseLengthValid = driverLicenceNum.length >= kDriverLicenseMinimumLength &&
    driverLicenceNum.length <= kDriverLicenseMaximum;
    if (!([driverLicenceNum rangeOfString: @"^[0-9A-Z]*$" options:NSRegularExpressionSearch].location != NSNotFound && isDriverLicenseLengthValid)) {
        
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please enter a valid Driver's License Number" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
        
    }
    
    if (!([stateCode rangeOfString: @"^(?-i:A[LKSZRAEP]|C[AOT]|D[EC]|F[LM]|G[AU]|HI|I[ADLN]|K[SY]|LA|M[ADEHINOPST]|N[CDEHJMVY]|O[HKR]|P[ARW]|RI|S[CD]|T[NX]|UT|V[AIT]|W[AIVY])$" options:NSRegularExpressionSearch].location != NSNotFound && stateCode.length == kStateCodeLength)) {
        
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please enter a valid 2 letter State code" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
    
        return;
    }
    
    if (IS_EMPTY(address)) {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please enter the address to continue" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    } else if (address.length < kAddressMinimumLength ) {
        NSString *message = [NSString stringWithFormat:[@"Address must be at least %i characters" localized], kAddressMinimumLength];
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:message
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (!self.imgAckCheckBox.isSelected) {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"You must acknowledge receipt of the Summary of Your Rights Under the Fair Credit Reporting Act" localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    // validation passed
    // remove previously cached first + last name -> FCRA form validated data must be submitted in case they entered nicknames
    
    DSAddress *dsAddress = [DSAddress new];
    dsAddress.zipCode = currentZip;
    dsAddress.address = address;
    
    DSDriver *driver = self.coordinator.driver;
    driver.user.address = dsAddress;
    driver.user.firstname = firstName;
    driver.user.lastname = lastName;
    driver.user.middleName = middleName;
    driver.user.dateOfBirth = self.dateOfBirth;
    driver.ssn = ssn;
    driver.licenseNumber =  driverLicenceNum;
    driver.licenseState = stateCode;
    
    [self.coordinator showNextScreenFromScreen:DSScreenFCRARights];
}

#pragma mark - UITextField

- (void)addEdgeInsetsToTextFields {
    const CGFloat leftPadding = 25;
    [self.txtAddress addLeftPadding:leftPadding];
    [self.txtCurrentZip addLeftPadding:leftPadding];
    [self.txtDOB addLeftPadding:leftPadding];
    [self.txtFirstName addLeftPadding:leftPadding];
    [self.txtLastName addLeftPadding:leftPadding];
    [self.txtMiddleName addLeftPadding:leftPadding];
    [self.txtSSN addLeftPadding:leftPadding];
    [self.txtState addLeftPadding:leftPadding];
    [self.txtDL addLeftPadding:leftPadding];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // TODO: First, middle, last name, state fields should only accept letters
    // TODO: date of birth, zip code, SSN, DL fields should only accept numbers maybe dashes/slashes
    
    //check delete key
    if (range.length == 1 && string.length == 0) {
        DBLog(@"backspace tapped");
        return YES;
    }
    
    if (textField == self.txtSSN) {
        
        NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *chSet = [NSCharacterSet characterSetWithCharactersInString:string];
        
        if (![digits isSupersetOfSet:chSet]) {
            return NO;
        }
        
        NSString *oldText = textField.text;
        
        NSString *completeText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (string.length > 0) {
            if (textField.text.length == kFirstSlashIndexToAdd || textField.text.length == kSecondSlashIndexToAdd) {
                textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
                return NO;
            } else if (completeText.length > kSSNLength) {
                textField.text = oldText;
                return NO;
            }
        } else {
            if (completeText.length == kFirstSlashIndexToAdd + 1 || completeText.length == kSecondSlashIndexToAdd + 1) {
                textField.text = [completeText substringToIndex:completeText.length - 1];
                return NO;
            }
        }
    }
    
    if (textField == self.txtMiddleName && self.imgMiddleNameCheckBox.isSelected) {
        return NO;
    }
    
    //Driver License
    if (textField == self.txtDL) {
        //FIX RA-5903 prevent infinite on Driver License after replace with uppercase
        if (self.txtDL.text.length >= kDriverLicenseMaximum) {
            return NO;
        }
        
        NSString *textUpper = [textField.text stringByReplacingCharactersInRange:range withString:string].uppercaseString;
        textField.text = textUpper;
        return NO;
    }
    
    //FIX RA-5903 Implement check for infinite TextField length <= 255
    BOOL shouldChange = YES;
    
    // prevent crashing undo
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;    
    shouldChange = newLength <= kTextFieldMaxLength;
    
    return shouldChange;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    
    if (textField == self.txtDOB) {
        [self dismissKeyBoard];
        [self setupDatePickerPopup];
        [self.popupDOB show];
        
        [self dateChanged:self.dobPicker];
    }

}

#pragma mark- IBACTIONS

- (IBAction)btnCheckPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    if (button == self.imgMiddleNameCheckBox) {
        self.txtMiddleName.text = @"";
        self.txtMiddleName.enabled = !button.selected;
    }
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender {
    self.activeField = nil;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark- Date Picker popup

- (void)setupDatePickerPopup {
    self.popupDOB = [KLCPopup popupWithContentView:self.viewDatePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    self.dateOfBirth = sender.date;
}

- (void)setDateOfBirth:(NSDate *)dateOfBirth {
    _dateOfBirth = dateOfBirth;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    self.txtDOB.text = [dateFormatter stringFromDate:dateOfBirth];
}

@end
