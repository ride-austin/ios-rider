//
//  DriverDisclosureViewController.m
//  Ride
//
//  Created by Abdul Rehman on 17/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverDisclosureViewController.h"
#import "FlatButton.h"
#import "NSString+Utils.h"
#import "RADriverAPI.h"
#import "Ride-Swift.h"
#import "UIImage+Utils.h"
#import "WebViewController.h"

typedef void(^SignUpCompletion)(NSError *error);
typedef void(^CarPhotoUploaded)(NSError *error);

@interface DriverDisclosureViewController ()

//IBOutlets
@property (weak, nonatomic) IBOutlet UITextView *lblTermAndCondition;

@property (nonatomic, assign) BOOL check;

@end

@implementation DriverDisclosureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Terms and Conditions" localized];
    self.check = NO;
    [self configureData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureData {
    __weak __typeof__(self) weakself = self;
    if (self.regConfig.driverTerms) {
        self.lblTermAndCondition.text = self.regConfig.driverTerms;
    } else {
        [self showHUD];
        [RADriverAPI getDriverTermsAtURL:self.regConfig.cityDetail.driverRegistrationTermsURL withCompletion:^(NSString * _Nullable terms, NSError * _Nullable error) {
            [self hideHUD];
            if (error) {
                
                RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                [option addAction:[RAAlertAction actionWithTitle:[@"Retry" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }]];
                
                [RAAlertManager showErrorWithAlertItem:error andOptions:option];
                
            } else {
                self.regConfig.driverTerms    = terms;
                self.lblTermAndCondition.text = terms;
            }
        }];
    }
}

#pragma mark- IBActions

- (IBAction)btnCheckPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
}

- (IBAction)btnContinuePressed:(id)sender {
    if (self.imgCheckBox.selected) {
        
        __weak DriverDisclosureViewController *weakSelf = self;
        
        [self showHUD];
        [self.btContinue setEnabled:NO];
        [self.coordinator submitRegistrationWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                [weakSelf hideHUD];
                [weakSelf.btContinue setEnabled:YES];
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            } else {
                [[RASessionManager sharedManager] reloadCurrentRiderWithCompletion:^(RARiderDataModel *rider, NSError *error) {
                    [weakSelf hideHUD];
                    [weakSelf.coordinator showNextScreenFromScreen:DSScreenTermsAndConditions];
                }];
            }
        }];
        
    } else {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[@"OK" localized]
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSString.accessibleAlertTitleRideAustin
                                                                       message:[@"Please agree to continue" localized]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
