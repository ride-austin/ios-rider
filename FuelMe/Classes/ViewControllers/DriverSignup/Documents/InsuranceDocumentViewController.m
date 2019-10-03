//
//  InsuranceDocumentViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DSCarInsuranceViewModel.h"
#import "InsuranceDocumentViewController.h"
#import "KLCPopup.h"
#import "NSString+Utils.h"
#import "RAMacros.h"
#import "RAPhotoPickerControllerManager.h"
#import "Ride-Swift.h"
#import "UIImage+Ride.h"

#define kHeightImageContainerIphone4 158.0

@interface InsuranceDocumentViewController ()
@property (nonatomic) DSCarInsuranceViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UIImageView *imgInsurance;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightImageContainer;

@end

@implementation InsuranceDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)configureUI {
    
    //Configure iPhone4S
    if (IS_IPHONE4 || IS_IPHONE4S) {
        self.constraintHeightImageContainer.constant = kHeightImageContainerIphone4;
    }
    
    //Setup Textfield Expiration Date
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.txtExpirationDate.bounds.size.height)];
    self.txtExpirationDate.leftView = leftView;
    self.txtExpirationDate.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.txtExpirationDate.bounds.size.height)];
    UIImageView *iconCalendar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-calendar"]];
    [iconCalendar setBounds:CGRectMake(0, 0, 18, 20)];
    [rightView addSubview:iconCalendar];
    iconCalendar.center = rightView.center;
    self.txtExpirationDate.rightView = rightView;
    self.txtExpirationDate.rightViewMode = UITextFieldViewModeAlways;
    
    self.txtExpirationDate.layer.borderWidth = 1;
    self.txtExpirationDate.layer.borderColor = [UIColor grayColor].CGColor;
    self.txtExpirationDate.layer.cornerRadius = 3.0;
    self.txtExpirationDate.layer.masksToBounds = YES;
    
    //Setup Date Picker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate new];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.insuranceViewModel;
    self.title = self.viewModel.headerText;
    
    if (self.viewModel.cachedImage) {
        [self setImageSelected:self.viewModel.cachedImage];
    }
    
    if ([self.coordinator.driver.insuranceExpiryDate isKindOfClass:NSDate.class]) {
        [self setDateSelected:self.coordinator.driver.insuranceExpiryDate];
        self.datePicker.date = self.coordinator.driver.insuranceExpiryDate;
    }
}

- (void)setDateSelected:(NSDate *)date {
    self.txtExpirationDate.text = [self.formatter stringFromDate:date];
}

- (void)setImageSelected:(UIImage *)image {
    self.imgInsurance.image = image;
}

- (IBAction)takePhotoPressed:(id)sender {
    [self.view endEditing:YES];
    
    __weak InsuranceDocumentViewController *weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        } else {
            BOOL valid = [weakSelf isImageValid:image];
            if (valid) {
                CGFloat maxArea = 480000;
                image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            }
            UIImage *validImage = valid ? image : nil;
            [weakSelf.viewModel saveImage:validImage];
            [weakSelf setImageSelected:validImage];
        }
    } cancelledBlock:nil];
}

- (void)didTapNext {
    if (!self.coordinator.driver.insuranceExpiryDate) {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationDateMessage
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (!self.viewModel.cachedImage) {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessage
                                    andOptions:[RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive]];
        return;
    }
    
    [self.coordinator showNextScreenFromScreen:DSScreenCarInsurance];
}

- (NSDateFormatter*)formatter{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
    }
    return formatter;
}

- (void)dateChanged:(UIDatePicker*)sender {
    self.coordinator.driver.insuranceExpiryDate = sender.date;
    [self setDateSelected:self.coordinator.driver.insuranceExpiryDate];
}

#pragma mark - UITextfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.txtExpirationDate) {
        [self.view endEditing:YES];
        self.datePopup = [KLCPopup popupWithContentView:self.datePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [self.datePopup show];
    }
}

@end
