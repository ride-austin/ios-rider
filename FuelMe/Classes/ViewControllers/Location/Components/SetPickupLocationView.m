//
//  SetPickupLocationView.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SetPickupLocationView.h"

#import "NSString+Utils.h"
#import "UIView+Loading.h"

@interface SetPickupLocationView()

@property (weak, nonatomic) IBOutlet UILabel *lblPickupTime;
@property (weak, nonatomic) IBOutlet UIView *viewSetLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *lblNotAvailableAtYourLocation;

@end

@implementation SetPickupLocationView

- (instancetype)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.anchorPoint = CGPointMake(0.5, 1.0);
        [self.btnSetPickupLocation addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)disableSetPickUpButton {
    self.alpha = 0.5;
    self.btnSetPickupLocation.enabled = NO;
}

- (void)enableSetPickUpButton {
    self.alpha = 1.0;
    self.btnSetPickupLocation.enabled = YES;
}

#pragma mark - When loading ETA

- (void)showLoadingAnimation {
    self.lblPickupTime.text = @"";
    [self.lblPickupTime showLoading];
}

- (void)showLoaded {
    if (self.lblPickupTime.carAnimationState != CarAnimationLoaded) {
        [self.lblPickupTime showLoaded];
    }
}

- (void)cleanLayers {
    [self.lblPickupTime cleanLayers];
}

- (void)updateETA:(NSInteger)currentActiveDriverETA {
    NSString *eta;
    if (currentActiveDriverETA != NSNotFound) {
        eta = currentActiveDriverETA < 60 ? [@"<1\nMIN" localized] : [NSString stringWithFormat:[@"%ld\nMIN" localized], currentActiveDriverETA / 60];
    }
    self.lblPickupTime.text = eta;
}

#pragma mark - When moving PIN

- (void)showAvailable {
    [self enableSetPickUpButton];
    [self.lblNotAvailableAtYourLocation setHidden:YES];
    [self.lblPickupTime setHidden:NO];
}

- (void)showNotAvailableWithTitle:(NSString *)title {
    [self disableSetPickUpButton];
    self.lblNotAvailableAtYourLocation.text = title ?: @"SET PICKUP LOCATION";
    [self.lblNotAvailableAtYourLocation setHidden:NO];
    [self.lblPickupTime setHidden:YES];
}

- (void)hidePickupButtonShowPin {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    [self.viewSetLocationButton setHidden:YES];
    [CATransaction commit];
}

- (void)showPickupButtonHidePin {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    [self.viewSetLocationButton setHidden:NO];
    [CATransaction commit];
}

@end
