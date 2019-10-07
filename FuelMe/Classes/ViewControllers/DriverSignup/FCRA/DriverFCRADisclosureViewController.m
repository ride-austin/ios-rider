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
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblAcknowlege;


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
    [self configureTexts];
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

-(void) configureTexts {
    self.lblLawTitle.text = @"RideAustin (“the Company”) may obtain information about you from a third party consumer reporting agency for contract purposes.  Thus, you may be the subject of a “consumer report” and/or an “investigative consumer report” which may include information about your character, general reputation, personal characteristics, and/or mode of living, and which can involve personal interviews with sources such as your neighbors, friends, or associates.  These reports may contain information regarding your criminal history, social security verification, motor vehicle records (“driving records”), verification of your education or employment history, or other background checks.";
    self.lblLawTitle.text = [self.lblLawTitle.text stringByReplacingOccurrencesOfString:@"RideAustin" withString:super.regConfig.appName];
    self.lblDetails.text = @"You have the right, upon written request made within a reasonable time, to request whether a consumer report has been run about you, and disclosure of the nature and scope of any investigative consumer report and to request a copy of your report.  Please be advised that the nature and scope of the most common form of investigative consumer report is an employment history or verification.  These searches will be conducted by Checkr, Inc., One Montgomery Street, Suite 2400, San Francisco, CA 94104 | (844) 824-3257 | candidate.checkr.com.  The scope of this disclosure is all-encompassing, however, allowing the Company to obtain from any outside organization all manner of consumer reports throughout the course of your contract to the extent permitted by law.";
    self.lblAcknowlege.text = @"I acknowledge receipt of the Disclosure Regarding Background Investigation and certify that I have read and understand this document.";
}
#pragma mark- IBACTIONS

- (IBAction)btnCheckPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
}

@end
