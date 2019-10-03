//
//  WomanOnlyViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/22/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "WomanOnlyViewController.h"
#import "FreeRidesViewController.h"
#import "NSString+Utils.h"
#import "RARideRequestManager.h"
#import "UIBarButtonItem+RAFactory.h"

@interface WomanOnlyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *lbOption;
@property (weak, nonatomic) IBOutlet UISwitch *btSwitch;

@end

@implementation WomanOnlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureText];
    [self configureButtons];
    
    RADriverTypeDataModel *config = [ConfigurationManager shared].global.womanOnly;
    [self updateSwitchWithConfiguration:(config != nil)];
}

- (void)configureButtons {
    ConfigReferRider *referRider = [ConfigurationManager shared].global.referRider;
    if (referRider.enabled) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem pinkWithTitle:@"Share" target:self action:@selector(didTapShare)];;
    }
    self.btSwitch.on = [RARideRequestManager sharedManager].isWomanOnlyModeOn;
}

- (void)updateSwitchWithConfiguration:(BOOL)isWomanOnlyEnabledInConfiguration {
    if (isWomanOnlyEnabledInConfiguration == NO) {
        [[RARideRequestManager sharedManager] setWomanOnlyModeOn:NO];
        __weak __typeof__(self) weakself = self;
        
        RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
        [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }]];
        
        [RAAlertManager showAlertWithTitle:@"" message:[@"This feature is temporarily disabled" localized] options:option];
    }
    self.btSwitch.on = [RARideRequestManager sharedManager].isWomanOnlyModeOn && isWomanOnlyEnabledInConfiguration;
}

- (void)configureText {
    RADriverTypeDataModel *config = [ConfigurationManager shared].global.womanOnly;
    NSString *subtitle  = config.displaySubtitle ?: [@"You can enable booking Female Drivers" localized];
    NSString *title     = config.displayTitle ?: [@"Female Driver Mode" localized];
    
    self.lbSubtitle.text = subtitle;
    self.lbOption.text   = title;
    self.title           = title;
}

- (void)didTapShare {
    FreeRidesViewController *vc = [FreeRidesViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)switchDidChange:(UISwitch *)sender {
    if ([[RARideRequestManager sharedManager] currentRideRequest]) {
        sender.on = !sender.on;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:[@"Request On going" localized] message:[@"Please cancel the request to change your woman only mode" localized] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        [[RARideRequestManager sharedManager] setWomanOnlyModeOn:sender.on];
        if (self.delegate) {
            [self.delegate womanOnlyModeChanged];
        }
    }
}

@end
