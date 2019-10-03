//
//  DriverFCRADisclosureViewController.m
//  Ride
//
//  Created by Carl von Havighorst on 7/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverFCRADisclosureViewController.h"
#import "NSString+Utils.h"
#import "Ride-Swift.h"

@interface DriverFCRADisclosureViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblLawTitle;
@property (nonatomic,assign)BOOL checkAck;

@end

@implementation DriverFCRADisclosureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    
    [self.view addGestureRecognizer:singleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    [self.scrollView setCanCancelContentTouches:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    
    self.lblLawTitle.text = [self.lblLawTitle.text stringByReplacingOccurrencesOfString:@"RideAustin" withString:super.regConfig.appName];
}

- (void)dismissKeyBoard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [@"FCRA Disclosure" localized];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)didTapNext {
    if (!self.confirmAcknowledgementCheckBoxButton.isSelected) {
        [RAAlertManager showAlertWithTitle:super.regConfig.appName
                                   message:[@"Please acknowledge receipt of the Disclosure Regarding Background Investigation and certify that You have read and understand this document." localized]
                                   options:[RAAlertOption optionWithState:StateActive]];

    } else {
        [self.coordinator showNextScreenFromScreen:DSScreenFCRADisclosure];
    }
}

#pragma mark- IBACTIONS

- (IBAction)btnCheckPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
}

@end
