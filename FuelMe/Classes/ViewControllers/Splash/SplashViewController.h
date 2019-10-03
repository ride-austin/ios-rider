//
//  SplashViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "FlatButton.h"
#import "RACity.h"

@class SplashViewController;
@protocol SplashViewControllerDelegate

- (void)splashViewControllerDidTapLogin:(SplashViewController *)splashViewController;
- (void)splashViewControllerDidTapRegister:(SplashViewController *)splashViewController;

@end

@interface SplashViewController : BaseViewController

//IBOutlets
@property (weak, nonatomic) id<SplashViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet FlatButton *loginButton;
@property (weak, nonatomic) IBOutlet FlatButton *createButton;
@property (weak, nonatomic) IBOutlet UIView *authViewContainer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *serverControl;
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UIImageView *ivWhiteLogo;

@property(nonatomic, strong) NSString *oldEnv;

@end
