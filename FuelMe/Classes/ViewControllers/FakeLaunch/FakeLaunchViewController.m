//
//  FakeLaunchViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "FakeLaunchViewController.h"

#import "AppConfig.h"
#import "LocationService.h"
#import "NSDate+Utils.h"
#import "PersistenceManager.h"
#import "PushNotificationSplitFareManager.h"
#import "RADeviceCheck.h"
#import "RAEnvironmentManager.h"
#import "RARideManager.h"
#import "RASessionManager.h"
#import "UIBarButtonItem+RAFactory.h"

#import <BugfenderSDK/BugfenderSDK.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <Stripe/STPAPIClient.h>
#import <Stripe/STPPaymentConfiguration.h>

@interface FakeLaunchViewController (ThirdPartyLibraries)

- (void)setupThirdPartyLibraries;

@end

@interface FakeLaunchViewController () <GMSMapViewDelegate>

@property (nonatomic) NSDictionary *launchOptions;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
/**
 There are cases where cancelPreviousPerformRequestsWithTarget is not able to cancel the animation, so we added this flag
 */
@property (atomic) BOOL shouldCancelAnimation;

@end

@implementation FakeLaunchViewController

#pragma mark - Init

- (instancetype)initWithLaunchOptions:(NSDictionary *)launchOptions {
    if (self = [super init]) {
        _launchOptions = launchOptions;
        
        __weak __typeof__(self) weakself = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kDidSignoutNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            weakself.shouldCancelAnimation = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:weakself selector:@selector(animateMap:) object:nil];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self configureOneTimeResources];
    [self configureMapAfterOneTimeResources];
}

#pragma mark - Configure UI

- (void)configureLayout {
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:234/255.0 blue:226/255.0 alpha:1.0];
    
    UIView *whiteView = [UIView new];
    whiteView.translatesAutoresizingMaskIntoConstraints = NO;
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    self.navigationBar = [UINavigationBar new];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.navigationBar];
    
    UIImageView *imgLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoRideAustin"]];
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110.0, 30.0)];
    [imgLogo setFrame:titleView.bounds];
    [titleView addSubview:imgLogo];
    
    UIBarButtonItem *menuItem = [UIBarButtonItem defaultImageName:@"menu-icon" target:nil action:nil];
    UIBarButtonItem *findItem = [UIBarButtonItem defaultImageName:@"find-current-location-icon" target:nil action:nil];
    UINavigationItem *navItems = [UINavigationItem new];
    navItems.titleView = titleView;
    navItems.leftBarButtonItem = menuItem;
    navItems.rightBarButtonItem = findItem;
    self.navigationBar.items = @[navItems];
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;

    NSLayoutConstraint *navigationBarTopConstraint;
    
    if (@available(iOS 11, *)) {
        navigationBarTopConstraint = [self.navigationBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
    } else {
        navigationBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    }
    
    [NSLayoutConstraint activateConstraints:
     @[
       [whiteView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
       [whiteView.heightAnchor constraintEqualToConstant:60],
       [whiteView.leadingAnchor constraintEqualToAnchor:self.view.compatibleLeadingAnchor],
       [whiteView.trailingAnchor constraintEqualToAnchor:self.view.compatibleTrailingAnchor],
       
       [self.navigationBar.leadingAnchor  constraintEqualToAnchor:self.view.compatibleLeadingAnchor],
       [self.navigationBar.trailingAnchor constraintEqualToAnchor:self.view.compatibleTrailingAnchor],
       navigationBarTopConstraint
       ]];
}

#pragma mark - Configure Resources

- (void)configureOneTimeResources {
    [NSDate trueDate];
    [RADeviceCheck deviceIdentifier];
    [self setupLocationServices];
    [self setupThirdPartyLibraries];
    [self setupAppearance];
    [self setupNotifications];
    [self setupWithLaunchOptions];
    [self setupBugFender];
}

- (void)configureMapAfterOneTimeResources {
    if ([self shouldSkipMapAnimation]) {
        [self.delegate didFinishLaunching];
    } else {
        GMSMapView *mapView = [[GMSMapView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:mapView];
        mapView.translatesAutoresizingMaskIntoConstraints = NO;
        mapView.delegate = self;
        mapView.userInteractionEnabled = NO;
        [mapView setPadding:UIEdgeInsetsMake(0, 0, kGoogleMapInitialBottomPadding, 0)];
        
        [NSLayoutConstraint activateConstraints:
         @[
           [mapView.topAnchor constraintEqualToAnchor:self.navigationBar.bottomAnchor],
           [mapView.bottomAnchor constraintEqualToAnchor:self.view.compatibleBottomAnchor],
           [mapView.leadingAnchor constraintEqualToAnchor:self.view.compatibleLeadingAnchor],
           [mapView.trailingAnchor constraintEqualToAnchor:self.view.compatibleTrailingAnchor]
           ]];
        
        [mapView setCamera:[GMSCameraPosition cameraWithLatitude:30.249279 longitude:-97.739173 zoom:10.234578]];
    }
}

- (BOOL)shouldSkipMapAnimation {
    if (UIAccessibilityIsVoiceOverRunning()) {
        return YES;
    }
    switch ([RARideManager sharedManager].currentRide.status) {
        case RARideStatusUnknown:
        case RARideStatusNone:
        case RARideStatusPrepared:
            return NO;
        case RARideStatusRequesting:
        case RARideStatusRequested:
        case RARideStatusNoAvailableDriver:
        case RARideStatusRiderCancelled:
        case RARideStatusDriverCancelled:
        case RARideStatusAdminCancelled:
        case RARideStatusDriverAssigned:
        case RARideStatusDriverReached:
        case RARideStatusActive:
        case RARideStatusCompleted:
            return YES;
    }
}

- (void)setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:7.0/255.0 green:13.0/255.0 blue:22.0/255.0 alpha:1.0]];
    
    UIFont *font = [UIFont fontWithName:FontTypeLight size:19];
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    titleBarAttributes[NSFontAttributeName] = font;
    titleBarAttributes[NSForegroundColorAttributeName] = UIColor.barButtonGray;
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back-icon"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back-icon"]];
    
    font = [UIFont fontWithName:FontTypeRegular size:15];
    
    //configure UIBarButton
    UIColor *disabledColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    UIColor *enabledColor  = [UIColor colorWithRed:2.0/255.0   green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    NSMutableDictionary *disabledAtt = [NSMutableDictionary dictionaryWithDictionary:[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateDisabled]];
    disabledAtt[NSFontAttributeName] = font;
    disabledAtt[NSForegroundColorAttributeName] = disabledColor;
    
    NSMutableDictionary *enabledAtt = [NSMutableDictionary dictionaryWithDictionary:[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    enabledAtt[NSFontAttributeName] = font;
    enabledAtt[NSForegroundColorAttributeName] = enabledColor;
    [[UIBarButtonItem appearance] setTitleTextAttributes:enabledAtt forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAtt forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTintColor:[UIColor barButtonGray]];
}

- (void)setupLocationServices {
    BOOL isLocationServiceAvailable = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
                                      [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    if (isLocationServiceAvailable) {
        [[LocationService sharedService] start];
    }
}

- (void)setupNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)setupWithLaunchOptions {
    [[PushNotificationSplitFareManager sharedManager] didFinishLaunchingWithOptions:self.launchOptions];
}

- (void)setupBugFender {
    [Bugfender activateLogger:[AppConfig bugFenderKey]];
    [Bugfender setPrintToConsole:NO];
}

#pragma mark - GMSMapView Delegate

- (void)mapViewDidStartTileRendering:(GMSMapView *)mapView {
    [self performSelector:@selector(animateMap:) withObject:mapView afterDelay:5.0];
}

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
    [self animateMap:mapView];
}

- (void)animateMap:(GMSMapView *)mapView {
    if (self.shouldCancelAnimation) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateMap:) object:mapView];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CLLocation *currentLocation = [LocationService myValidLocation];
        if (!currentLocation || ![RASessionManager sharedManager].isSignedIn) {
            [self.delegate didFinishLaunching];
            return;
        }
        CGFloat const animationDuration = 1.6;
        [CATransaction begin];
        [CATransaction setAnimationDuration:animationDuration];
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:currentLocation.coordinate zoom:kGMSMaxZoomLevel - 4.0];
        [mapView animateToCameraPosition:position];
        [CATransaction commit];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate didFinishLaunching];
        });
    });
}

@end

#pragma mark - Third Party Libraries

@implementation FakeLaunchViewController (ThirdPartyLibraries)

- (void)setupThirdPartyLibraries {
    [self setupStripe];
}

- (void)setupStripe {
    if ([[RAEnvironmentManager sharedManager] isTestMode]) {
        [Stripe setDefaultPublishableKey:[AppConfig stripeKeyQA]];  
    } else {
        [Stripe setDefaultPublishableKey:[AppConfig stripeKey]];
    }
    [[STPPaymentConfiguration sharedConfiguration] setAppleMerchantIdentifier:[AppConfig appleMerchantIdentifier]];
}

@end
