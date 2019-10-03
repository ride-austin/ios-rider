//
//  DriverFCRAAckViewController.m
//  Ride
//
//  Created by Carl von Havighorst on 7/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverFCRAAckViewController.h"
#import "NSString+Utils.h"
#import "RAMacros.h"
#import "Ride-Swift.h"
@interface DriverFCRAAckViewController ()

@property (weak, nonatomic) UITextField *activeField;

@end

@implementation DriverFCRAAckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    
    [self.view addGestureRecognizer:singleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    [self.scrollView setCanCancelContentTouches:YES];
    [self.scrollView setUserInteractionEnabled:YES];

    UIView *paddingView8 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    
    self.fullNameTextField.leftView= paddingView8;
    self.fullNameTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)dismissKeyBoard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];

    self.title = [@"FCRA Disclosure" localized];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    
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
    NSString *userEnteredUpperCase = [[[NSString stringWithString: self.fullNameTextField.text] uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *expectedFullName = [self.coordinator.driver.user.fullName.uppercaseString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (userEnteredUpperCase.length == 0 || ![userEnteredUpperCase isEqualToString:expectedFullName]) {
        [RAAlertManager showAlertWithTitle:super.coordinator.regConfig.appName
                                   message:[@"Please digitally sign with Your full name as entered previously, including first name, middle names and last name." localized]
                                   options:[RAAlertOption optionWithState:StateActive]];
    } else {
        [self.coordinator showNextScreenFromScreen:DSScreenFCRAAcknowledge];
    }
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender {
    self.activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender {
    self.activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    
    // prevent crashing undo
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    shouldChange = newLength <= kTextFieldMaxLength;
    
    return shouldChange;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
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

@end
