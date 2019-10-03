//
//  BaseRegistrationViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/5/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"
#import "NSString+Utils.h"
#import "RAHelpBarView.h"
#import "Ride-Swift.h"
#import "UIImage+Ride.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BaseRegistrationViewController () <RAHelpBarViewDelegate>

@property (weak, nonatomic) IBOutlet RAHelpBarView *vHelpBar;

@end

@implementation BaseRegistrationViewController

- (id)init {
    self = [super init];
    if (self) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureHelpBar];
}

- (void)configureHelpBar {
    self.vHelpBar.delegate = self;
    [self.vHelpBar.ivLogo sd_setImageWithURL:self.coordinator.regConfig.cityDetail.logoURLwhite];
}

- (void)updateHelpBarWithCityDetail:(RACityDetail *)cityDetail {
    [self.vHelpBar.ivLogo sd_setImageWithURL:cityDetail.logoURLwhite];
}

#pragma mark - RAHelpBarViewDelegate

- (void)didTapHelpBar {
     [self showMessageViewWithRideID:nil cityID:self.coordinator.regConfig.city.cityID];
}

- (BOOL)isImageValid:(UIImage *)image{
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        NSString *message = [@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized];
        [RAAlertManager showErrorWithAlertItem:message
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

- (ConfigRegistration *)regConfig {
    return self.coordinator.regConfig;
}

@end
