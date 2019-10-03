//
//  DriverTNCBackViewController.m
//  Ride
//
//  Created by Carlos Alcala on 2/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSChauffeurViewModel.h"
#import "DriverTNCBackViewController.h"
#import "NSString+Utils.h"
#import "Ride-Swift.h"
#import "UIImage+Ride.h"

@interface DriverTNCBackViewController()

@property (nonatomic) DSChauffeurViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITextView *tvTitle1;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle1;

@end

@implementation DriverTNCBackViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.chauffeurViewModel;
    if (self.viewModel.cachedBackImage) {
        [self setPhoto:self.viewModel.cachedBackImage];
    }

    if ([self.viewModel.expirationDate isKindOfClass:NSDate.class]) {
        self.datePicker.date = self.viewModel.expirationDate;
        [self setDate:self.viewModel.expirationDate];
    }
    
    self.title = self.viewModel.headerTextBack;
    self.tvTitle1.text = self.viewModel.title1Back;
    self.tvSubtitle1.text = self.viewModel.subtitle1Back;
}

- (void)setPhoto:(UIImage *)photo {
    self.imagePhoto.image = photo;
}

- (void)setDate:(NSDate *)date {
    self.expirationDate.text = [self.formatter stringFromDate:date];
}

#pragma mark - Configure Helper Functions

- (void)configureUI {
    //Setup Textfield Expiration Date
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.expirationDate.bounds.size.height)];
    self.expirationDate.leftView = leftView;
    self.expirationDate.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.expirationDate.bounds.size.height)];
    UIImageView *iconCalendar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-calendar"]];
    [iconCalendar setBounds:CGRectMake(0, 0, 18, 20)];
    [rightView addSubview:iconCalendar];
    iconCalendar.center = rightView.center;
    self.expirationDate.rightView = rightView;
    self.expirationDate.rightViewMode = UITextFieldViewModeAlways;
    
    self.expirationDate.layer.borderWidth = 1;
    self.expirationDate.layer.borderColor = [UIColor grayColor].CGColor;
    self.expirationDate.layer.cornerRadius = 3.0;
    self.expirationDate.layer.masksToBounds = YES;
    
    //Setup Date Picker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate new];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    __weak typeof(self) weakSelf = self;
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        BOOL valid = [weakSelf isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        weakSelf.viewModel.didConfirmBack = NO;
        UIImage *validImage = valid ? picture : nil;
        [weakSelf.viewModel saveBackImage:validImage];
        [weakSelf setPhoto:validImage];
    } cancelledBlock:nil];
}

//
//    RA-2266
//    iPhone 6/6+, iPhone 5/5S, iPhone 4S(8 MP) - 3264 x
//    2448 pixels
//    iPhone 4, iPad 3, iPodTouch(5 MP) - 2592 x 1936 pixels
//    Size Validation based on the minium iPhone4/iPod Photo Resolutions above
//
- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

- (void)didTapNext {
    
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];
        return;
    }
    
    //RA-8657 - TNC card not required
    if (!self.viewModel.cachedBackImage) {
        __weak DriverTNCBackViewController *weakSelf = self;
        RAAlertOption *option = [RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive];
        [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:nil]];
        [option addAction:[RAAlertAction actionWithTitle:[@"Skip" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showNextRegistrationScreen];
        }]];
        
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessageBack
                                    andOptions:option];
        return;
    }
    
    if (!self.viewModel.expirationDate) {
        __weak DriverTNCBackViewController *weakSelf = self;
        RAAlertOption *option = [RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive];
        [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:nil]];
        [option addAction:[RAAlertAction actionWithTitle:[@"Skip" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showNextRegistrationScreen];
        }]];
        [RAAlertManager showErrorWithAlertItem:[@"Please select a valid date to continue." localized]
                                    andOptions:option];

        return;
    }
    
    if (self.viewModel.didConfirmBack) {
        [self showNextRegistrationScreen];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:self.viewModel.appName
                                                                    message:self.viewModel.confirmationMessageBack
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.viewModel.didConfirmBack = YES;
            [self showNextRegistrationScreen];
        }];
        UIAlertAction *no  = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:yes];
        [ac addAction:no];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)showNextRegistrationScreen {
    [self.coordinator showNextScreenFromScreen:DSScreenChauffeurPermitBack];
}

#pragma mark - Date Helper Functions

- (NSDateFormatter*)formatter{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
    }
    return formatter;
}

- (void)dateChanged:(UIDatePicker*)sender{
    self.viewModel.expirationDate = sender.date;
    [self setDate:self.viewModel.expirationDate];
}

#pragma mark - UITextfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.expirationDate) {
        [self.view endEditing:YES];
        self.datePopup = [KLCPopup popupWithContentView:self.datePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [self.datePopup show];
    }
}

@end
