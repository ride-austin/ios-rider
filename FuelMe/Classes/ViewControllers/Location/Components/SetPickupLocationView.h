//
//  SetPickupLocationView.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"

@interface SetPickupLocationView : RACustomView

@property (weak, nonatomic, nullable) IBOutlet UIButton *btnSetPickupLocation;

- (instancetype _Nonnull)initWithFrame:(CGRect)frame target:(id _Nonnull)target action:(SEL _Nonnull)action;

- (void)disableSetPickUpButton;
- (void)enableSetPickUpButton;

#pragma mark - When loading ETA
- (void)showLoadingAnimation;
- (void)showLoaded;
- (void)cleanLayers;
- (void)updateETA:(NSInteger)currentActiveDriverETA;

#pragma mark - When moving PIN
- (void)showNotAvailableWithTitle:(NSString * _Nullable)title;
- (void)showAvailable;

- (void)hidePickupButtonShowPin;
- (void)showPickupButtonHidePin;

@end
