//
//  RAUpgradeRequestPopUpView.m
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAUpgradeRequestPopUpView.h"

@interface RAUpgradeRequestPopUpView (Accessibility)

- (void)configureAccessibility;

@end

static NSString *const kUpgradeRequestRideID = @"kUpgradeRequestRideID";

@implementation RAUpgradeRequestPopUpView

+ (RAUpgradeRequestPopUpView*)showUpgradeRequestPopUpViewWithDelegate:(id<RAPopUpViewDelegate>)delegate source:(NSString*)source target:(NSString*)target surgeFactor:(double)surgeFactor rideID:(NSString *)rideID {

    RAUpgradeRequestPopUpView *popup = [[RAUpgradeRequestPopUpView alloc] initWithFrame:CGRectMake(0, 0, 280, 415)];
    popup.delegate = delegate;
    popup.mainView.layer.cornerRadius = 8;
    [popup.headerImageView setImage:[UIImage imageNamed:@"popupHeader"]];
    [popup.iconImageView setImage:[UIImage imageNamed:@"hourGlassIcon"]];
    [popup.titleLabel setText:[NSString stringWithFormat: @"Do you confirm an upgrade to %@ class?", target]];
    [popup.messageLabel setText:[NSString stringWithFormat: @"Your driver requested a car class upgrade from %@ to %@", source, target]];
    [popup.additionalIconImageView setImage:[UIImage imageNamed:@"Icon-p"]];
    [popup.additionalInfo1Label setText:[NSString stringWithFormat: @"PRIORITY FARE: %.2fX", surgeFactor]];
    [popup.additionalInfo2Label setText:@"more than normal fare"];
    [popup.leftButton setTitle:@"YES" forState:UIControlStateNormal];
    [popup.rightButton setTitle:@"NO" forState:UIControlStateNormal];
    [popup.closeButton setBackgroundImage:[UIImage imageNamed:@"whiteCancel"] forState:UIControlStateNormal];
    popup.additionalViewHidden = surgeFactor<=1;
    popup.userInfo = @{kUpgradeRequestRideID: rideID};
    
    [popup configureAccessibility];
    
    [popup show];
    
    return popup;
}

- (NSString *)rideID {
    return self.userInfo[kUpgradeRequestRideID];
}

@end

@implementation RAUpgradeRequestPopUpView (Accessibility)

- (void)configureAccessibility {
    self.contentView.accessibilityIdentifier = @"CarUpgradeRequestAlert";
    self.messageLabel.accessibilityIdentifier = @"messageLabel";
    self.additionalInfo1Label.accessibilityIdentifier = @"priorityFareLabel";
    self.leftButton.accessibilityIdentifier = @"yesButton";
    self.rightButton.accessibilityIdentifier = @"noButton";
    self.closeButton.accessibilityIdentifier = @"cancelButton";
}

@end
