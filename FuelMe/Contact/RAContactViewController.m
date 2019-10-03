//
//  RAContactViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 4/3/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAContactViewController.h"
#import "NSString+Utils.h"
@interface RAContactViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSMS;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation RAContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDefaults];
    [self configureText];
}

- (void)configureDefaults {
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}

- (void)configureText {
    self.lbTitle.text = [@"Contact Driver" localized];
    self.lbSubtitle.text = [NSString stringWithFormat:@"Calling turned off because %@ is deaf or hard of hearing".localized, self.driverFirstName];
    
    [self.btnSMS setTitle:[NSString stringWithFormat:@"TEXT %@".localized, self.driverFirstName.uppercaseString] forState:UIControlStateNormal];
    self.btnClose.accessibilityLabel = @"Close";
}

- (IBAction)didTapSMS:(UIButton *)sender {
    self.didTapSMSBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didTapClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
