//
//  SplashViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "SplashViewController.h"

#import "AssetCityManager.h"
#import "ErrorReporter.h"
#import "FlatButton+FlatButton_StyleFacade.h"
#import "LocationService.h"
#import "NSString+Utils.h"
#import "PersistenceManager.h"
#import "RAEnvironmentManager.h"
#import "RAMacros.h"
#import "RARideManager.h"
#import "RAUpgradeManager.h"
#import "RideConstants.h"
#import "UIView+Animation.h"

#import <SDWebImage/UIImageView+WebCache.h>

typedef void(^UpdateUICompletion)(void);

@interface SplashViewController ()

@property (nonatomic) UIAlertController *internetAlert;

@end

@implementation SplashViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureLayout];
    
    if([[RASessionManager sharedManager] isSignedIn]) {
        [[LocationService sharedService] start];
    }
    
    __weak SplashViewController *weakSelf = self;
    [self hideAuthViewAndStartLoading:[RANetworkManager sharedManager].isNetworkReachable == NO];
    [self updateUIByCityWithCompletion:^{
        [weakSelf addObservers];
        [weakSelf showAuthViewAndStopLoading];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureEnviromentControl];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self addReachabilityObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.authViewContainer.alpha = 1.0;
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

- (void)dealloc {
    DBLog(@"Dealloc SplashViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureUI {
    [self.navigationController setNavigationBarHidden:YES];
    self.version.text = [RAEnvironmentManager sharedManager].version;
    self.version.accessibilityLabel = self.version.text;
    self.splashImage.alpha = 0;
}

- (void)configureLayout {

    NSLayoutConstraint *imgLogoTopConstraint;
    NSLayoutConstraint *authViewContainerBottomConstraint;
    
    if (@available(iOS 11, *)) {
        imgLogoTopConstraint = [self.ivWhiteLogo.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:48.0];
        authViewContainerBottomConstraint = [self.authViewContainer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    } else {
        imgLogoTopConstraint = [NSLayoutConstraint constraintWithItem:self.ivWhiteLogo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:48.0];
        authViewContainerBottomConstraint = [NSLayoutConstraint constraintWithItem:self.authViewContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    }
    
    [NSLayoutConstraint activateConstraints:@[imgLogoTopConstraint, authViewContainerBottomConstraint]];
}

- (void)updateUIByCityWithCompletion:(UpdateUICompletion)completion {
    [self configureAppLogo];
    [self configureButtonsStyle];
    [self showSplashBackgroundWithCompletion:completion];
}

- (void)configureAppLogo {
    RAGeneralInfo *config = [ConfigurationManager shared].global.generalInfo;
    self.ivWhiteLogo.alpha = 0;
    __weak SplashViewController *weakSelf = self;
    [self.ivWhiteLogo sd_setImageWithURL:config.logoURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.ivWhiteLogo.image = image ?: [AssetCityManager logoWhiteCurrentCity];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.ivWhiteLogo.alpha = 1;
        } completion:nil];
    }];
}

- (void)configureButtonsStyle {
    [self.loginButton applyLoginStyle];
    [self.createButton applyRegisterStyle];
    self.serverControl.backgroundColor = [UIColor clearColor];
    self.serverControl.tintColor = [AssetCityManager colorCurrentCity:Border];
}

- (void)configureEnviromentControl {
    self.serverControl.selectedSegmentIndex = [RAEnvironmentManager sharedManager].environment;
    self.serverControl.hidden = YES;
#ifdef TEST
    self.serverControl.hidden = NO;
#endif
}

- (void)showSplashBackgroundWithCompletion:(UpdateUICompletion)completion {
    RAGeneralInfo *config = [ConfigurationManager shared].global.generalInfo;
    __weak SplashViewController *weakSelf = self;
    [self.splashImage sd_setImageWithURL:config.splashURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.splashImage.image = image ?: [AssetCityManager defaultSplash];
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.splashImage.alpha = 1;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }];
}

#pragma mark - Observers

- (void)addObservers {
    __weak SplashViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidChangeCurrentCityType
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [weakSelf updateUIByCityWithCompletion:nil];
                                                  }];
}

#pragma mark - IBActions

- (IBAction)doLogin:(id)sender {
    [self.delegate splashViewControllerDidTapLogin:self];
}

- (IBAction)doRegister:(id)sender {
    [self.delegate splashViewControllerDidTapRegister:self];
}

- (IBAction)enviromentChanged:(id)sender {
    UISegmentedControl *serverControl = (UISegmentedControl*)sender;
    RAEnvironment selectedEnv = (RAEnvironment)serverControl.selectedSegmentIndex;
    switch (selectedEnv) {
        case RAQAEnvironment:
        case RAStageEnvironment:
            //FIX: RA-5442 register oldEnv before change
            self.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
            [self setEnviroment:selectedEnv];
            break;
        case RACustomEnvironment: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ride Austin" message:@"Please enter in server:" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = [RAEnvironmentManager sharedManager].serverUrl;
            }];
            
            __weak SplashViewController *weakSelf = self;
            UIAlertAction *customAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textField = [alert.textFields firstObject];
                
                //FIX: RA-5442 register oldEnv before change
                weakSelf.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
                
                [[RAEnvironmentManager sharedManager] setCustomServerURL:textField.text];
                [weakSelf setEnviroment:RACustomEnvironment];
            }];
            
            [alert addAction:customAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
            
        case RAProdEnvironment: {
        default:
            //FIX: RA-5442 register oldEnv before change
            self.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
            [self setEnviroment:RAProdEnvironment];
        }
            break;
    }
}

- (void)setEnviroment:(RAEnvironment)env {
    [RAEnvironmentManager sharedManager].environment = env;
    [[RANetworkManager sharedManager] reloadBaseURL];
    [ConfigurationManager needsReload];
}

- (void)addReachabilityObserver {
    __weak SplashViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self statusChangedBlock:^(RANetworkReachability networkReachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (networkReachability == RANetworkReachable) {
                [weakSelf hideHUD];
                [weakSelf.internetAlert dismissViewControllerAnimated:NO completion:^{
                    weakSelf.internetAlert = nil;
                }];
                [weakSelf updateUIByCityWithCompletion:^{
                    [weakSelf showAuthViewAndStopLoading];
                }];
            } else{
                if (weakSelf.internetAlert) {
                    return;
                }
                
                weakSelf.internetAlert = [RAAlertManager showAlertWithTitle:[@"No Connection" localized]
                                                                    message:[@"There is no connection to the internet. The app will continue when a connection is established." localized]
                                                                    options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
                [weakSelf hideAuthViewAndStartLoading:YES];
            }
        });
   }];
}

#pragma mark - Loaders

- (void)showAuthViewAndStopLoading {
    [self.authViewContainer showAnimated:^(BOOL finished) {
        [self hideHUD];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.loginButton);
    }];
}

- (void)hideAuthViewAndStartLoading:(BOOL)networkError {
    [self.authViewContainer setAlpha:0];
    if (networkError) {
        [self showConnectivityErrorHUD];
    } else{
        [self showHUD];
    }
}

@end
