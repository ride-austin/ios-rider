//
//  DSCarLicensePlateViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/11/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "DSCarLicensePlateViewController.h"

#import "Ride-Swift.h"
#import "FormValidator.h"

@interface DSCarLicensePlateViewController ()

@property (nonatomic) FormValidator *validator;
@property (nonatomic) DSCarLicensePlateViewModel *viewModel;
@property (nonatomic, weak) IBOutlet UITextField *licensePlateTextField;

@end

@implementation DSCarLicensePlateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    self.licensePlateTextField.leftView = paddingView;
    self.licensePlateTextField.leftViewMode = UITextFieldViewModeAlways;
    [self configureValidator];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.carLicensePlateViewModel;
    self.title = self.viewModel.headerText;
}

- (void)configureValidator {
    self.validator = [FormValidator validatorWithType:TFTypeLicensePlate];
    self.licensePlateTextField.delegate = self.validator;
}

- (IBAction)didTapNext:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if ([self.validator isValid:self.licensePlateTextField.text]) {
        self.coordinator.car.license = self.licensePlateTextField.text;
        [self.coordinator showNextScreenFromScreen:DSScreenCarLicensePlate];
    } else {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessage
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
    }
}

@end
