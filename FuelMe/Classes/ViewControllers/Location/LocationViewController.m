//
//  LocationViewController.m
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "LocationViewController.h"

#import "ApplePayHelper.h"
#import "AssetCityManager.h"
#import "BottomDrawerView.h"
#import "CarCategoriesManager.h"
#import "CLLocation+Utils.h"
#import "DNA.h"
#import "DriverInfoView.h"
#import "ErrorReporter.h"
#import "EstimatedFareViewController.h"
#import "FlatButton+FlatButton_StyleFacade.h"
#import "GeocoderService.h"
#import "GoogleMapsManager+Facade.h"
#import "LocationService.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "PersistenceManager.h"
#import "PickerAddressViewController.h"
#import "PriorityFareConfirmationViewController.h"
#import "PushNotificationSplitFareManager.h"
#import "RAActiveDriversManager.h"
#import "RAAddress.h"
#import "RAAddressButton.h"
#import "RAAlertView.h"
#import "RAConfigAPI.h"
#import "RACustomTextField.h"
#import "RAEnvironmentManager.h"
#import "RAEventsLongPolling.h"
#import "RAFavoritePlacesManager.h"
#import "RAMacros.h"
#import "RANotificationSlide.h"
#import "RAPlaceSearchManager.h"
#import "RARecentPlacesManager.h"
#import "RARideAPI.h"
#import "RARideCancellationTimer.h"
#import "RARideCommentsManager.h"
#import "RARideManager.h"
#import "RARideRequestManager.h"
#import "RARiderAPI.h"
#import "RASimpleAlertView.h"
#import "RASurgeAreaAPI.h"
#import "RAUpgradeManager.h"
#import "RAUpgradeRequestManager.h"
#import "RatingViewController.h"
#import "RatingViewModel.h"
#import "RequestRideView.h"
#import "RideConstants.h"
#import "RideCostDetailViewController.h"
#import "Ride-Swift.h"
#import "SMessageViewController.h"
#import "SetPickupLocationView.h"
#import "SplitFareInvitationAlert.h"
#import "SplitFareManager.h"
#import "TTTAttributedLabel.h"
#import "UIColor+HexUtils.h"
#import "UIView+Glow.h"
#import "UnratedRide.h" //can get rid of this when mainCoordinator handles presentation of RatingViewController
#import "UnratedRideManager.h"

#import <AudioToolbox/AudioToolbox.h>
#import <BugfenderSDK/BugfenderSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <PassKit/PassKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Shimmer/FBShimmeringView.h>

@interface LocationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblRequesting;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseRequesting;

@property (weak, nonatomic) IBOutlet UIView *viewAddressFields;
@property (weak, nonatomic) IBOutlet UIView *viewPickupField;
@property (weak, nonatomic) IBOutlet UIView *viewDestinationField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDestinationFieldTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddressContainerLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddressContainerTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddressContainerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCommentFieldTop;

@property (strong, nonatomic) IBOutlet UIView *pinViewWithTime;
@property (weak, nonatomic) IBOutlet UILabel *pinViewWithTime_min;

@property (strong, nonatomic) IBOutlet UIView *viewRoundUpAlert;

@property (nonatomic, strong) RARideLocationDataModel *preselectedSource;
@property (nonatomic, strong) RARideLocationDataModel *preselectedDestination;
@property (nonatomic, strong) NSString *preselectedComment;

@property (nonatomic, readonly) RARideRequest *currentRideRequest;

@property (nonatomic) RARideLocationDataModel *currentLocation;

//Outlets
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewShimmeringRequestingTopConstraint;

@property (nonatomic, weak) IBOutlet RAAddressButton *btPickupAddress;
@property (nonatomic, weak) IBOutlet RAAddressButton *btDestinationAddress;
@property (nonatomic, weak) IBOutlet RACustomTextField *pickUpCommentTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;

@property (nonatomic, strong) RANotificationSlide *offlineNotification;

/**
 Prompt to Cancel Ride
 */
@property (nonatomic, strong) RAAlertView * tripCancellationAlert;
@property (nonatomic, assign) CGFloat recentPlaceMarginBottom;


@property (weak, nonatomic) IBOutlet UIView *insertingView;


//ETA Destination
@property (weak, nonatomic) IBOutlet UIButton *btnETADestination;



//GoogleMaps
@property (nonatomic, strong) GoogleMapsManager *googleMapsManager;
@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;

//Requesting Top Bar
@property (weak, nonatomic) IBOutlet FBShimmeringView *viewShimmeringRequesting;

//Navigation Bar
@property (strong, nonatomic) UIBarButtonItem *btFindLocation;
@property (strong, nonatomic) UIBarButtonItem *btContact;

//Car Categories
@property (nonatomic, strong) NSArray<RACarCategoryDataModel*> *categories;
@property (nonatomic) RACarCategoryDataModel *currentSelectedCarCategory;

//Real Time Tracking
@property (nonatomic, strong) NSArray<Contact*> *contacts;

//Rating
@property (nonatomic) NSString *currentUnratedRide;

//Popups
@property (nonatomic, strong) KLCPopup * popupFareView;
@property (nonatomic, strong) KLCPopup * popupRoundUpAlert;

@property (nonatomic) NSInteger currentActiveDriverETA;

@property (nonatomic, strong) RARideCancellationTimer *rideCancellationTimer;

#pragma mark - Components created programatically

//Set Pickup Location View
@property (strong, nonatomic) SetPickupLocationView *viewSetPickupLocation;

//Bottom Drawer View
@property (strong, nonatomic) IBOutlet BottomDrawerView *viewCategoryMainView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintFareView;

//View Request Ride
@property (strong, nonatomic) IBOutlet RequestRideView *viewRequestRide;

//Driver Info View
@property (strong, nonatomic) DriverInfoView *viewDriver;
@property (strong, nonatomic) NSLayoutConstraint *constraintViewDriverTopToSuperViewBottom;

#pragma mark -

//flags
@property (nonatomic) BOOL needToPlayReachedSound;
@property (nonatomic, readonly, getter=isStartLocationSelected) BOOL startLocationSelected;
@property (nonatomic, readonly, getter=isDestinationLocationSelected) BOOL destinationLocationSelected;
@property (nonatomic) BOOL isLocationSelectedFromValidSource;
@property (nonatomic,assign) BOOL isAutoMoveEnabled;
@property (nonatomic) BOOL needsToResendDestinationChanged; //RA-3346
@property (nonatomic, assign) BOOL isSplitFareAlertDisplaying;
@property (nonatomic, assign) BOOL isOntripMarkersShown; //For showing both markers ontrip once
@property (nonatomic, assign) BOOL isDriverComingShown;
@property (nonatomic, getter=isSynchronizing) BOOL synchronizing;
@property (nonatomic, getter=isRetryingSynchronize) BOOL retryingSynchronize;
@property (nonatomic, assign) BOOL shouldRefreshMap;
@property (nonatomic) BOOL shouldHideBtnETADestination;

/*
 * @brief used to avoid any other thread changing the start address text (RA-9673).
 */
@property (nonatomic, getter=isSettingSource) BOOL settingSource;
/*
 * @brief Used to show alert or to not show when destination is changed.
 */
@property (nonatomic) BOOL riderChangedDestination;

//SplitFare Requested Alert
@property (nonatomic, strong) SplitFareInvitationAlert *splitFareRequestedAlert;

//RA-12018. Trying to reduce HUDs and view updates (visually). So First will check cached ride status and update view accordingly, then will synchronize ride (from server) in bg.
- (void)preLoadView;

@end


#pragma mark User Interaction

@interface LocationViewController (UserInteraction)

- (void)didTapMenuBarButton:(UIBarButtonItem *)sender;
- (void)didTapFindLocationBarButton:(UIBarButtonItem *)sender;
- (void)didTapSetPickupButton:(UIButton *)sender;
- (void)didTapContactDriver:(UIButton *)sender;
- (void)didTapFareEstimate:(UIButton *)sender;

#pragma mark - Round up
- (IBAction)btnYesRoundUpPressed:(UIButton *)sender;
- (IBAction)btnNoRoundUpPressed:(UIButton *)sender;
#pragma mark -
- (IBAction)btnCloseRequestPressed:(id)sender;


@end

#pragma mark - Ride Polling
#pragma mark - RidePolling Configuration

@interface LocationViewController (RidePollingConfiguration)

- (void)configureRideManager;

@end

#pragma mark RidePollingConsumer Delegate

@interface LocationViewController (RidePollingconsumerDelegate) <RARidePollingConsumerDelegate>

@end

#pragma mark Ride Engine

typedef void(^AppUpgradeCompletionBlock)(BOOL shouldUpgrade, BOOL isMandatory);

@interface LocationViewController (RideEngine)

- (void)checkAppUpgrade:(AppUpgradeCompletionBlock)completion;
- (void)synchronizeRideWithCompletion:(void(^)(void))handler;
- (void)performChangesOnRide:(NSDictionary*)changes;

@end

#pragma mark - UIUpdates

@interface LocationViewController (UIUpdates)

- (void)updateNavigationBarToDefault;
- (void)updateNavigationBarToTripStarted;
- (void)updateNavigationTitle:(NSString*)title;

- (void)updateUIWithRideStatus:(RARideStatus)status;

- (void)updateViewToState:(RALocationViewState)state;

- (void)setViewToStateClear;
- (void)setViewToStateInitial;
- (void)setViewToStatePrepared;
- (void)setViewToStateRequesting;
- (void)setViewToStateRideAssigned;
- (void)setViewToStateWaitingDriver;
- (void)setViewToStateDriverReached;
- (void)setViewToStateTripStarted;
- (void)setViewToStateRideCleanup;

- (void)updateDriverInfoAndUpdateTimers:(BOOL)shouldUpdateTimers;
- (void)updateActiveDriverLocation:(CLLocation*)driverLocation;
- (void)updateActiveDriverArrivalTime:(NSNumber*)arrivalTime;
- (void)updateEstimatedCompletionTime;

- (void)showOrHideStackedRideViewBasedOnPrecedingRide;
- (void)updatePrecedingRideMarker;

- (void)hideCommentsField;

@end

@interface LocationViewController (UIUpdatesMigration)

- (void)collapseViewCategoryMainView;

/**
 *  returns the constant to show or hide viewDriver bottomView
 *  it will always be visible if voice over is on
 */
//- (CGFloat)viewDriverHeightConstant:(BOOL)isVisible;
@end

#pragma mark - Events

@interface LocationViewController (Events)

- (void)observeEvents;
- (void)unobserveEvents;
- (void)eventsPollingHasReceivedNewEventNotification:(NSNotification *)notification;

@end

#pragma mark Active Drivers

@interface LocationViewController (ActiveDrivers)

- (void)startPollingForActiveDrivers;
- (void)stopPollingForActiveDrivers;

- (NSInteger)getETAFromActiveDrivers:(NSArray<RAActiveDriverDataModel*> *) activeDrivers;

@end

#pragma mark GoogleMaps

static const CGFloat kLocationViewControllerMapDefaultZoomAdjustment = 4;
#define kDefaultMapZoom (kGMSMaxZoomLevel-kLocationViewControllerMapDefaultZoomAdjustment)
static const CGFloat kLocationViewControllerMaxDistanceZoomBetweenCoords = 300;

@interface LocationViewController (GoogleMaps) <GMSMapViewDelegate>

- (void)configureMapWithCurrrentLocation;
- (void)configureMapWithLocation:(CLLocation*)location;
- (void)setUpMapWithLocation:(CLLocation*)location;
- (void)getMyCurrentLocationWithCompletion:(LocationResult)completion;

- (void)updatePadding;

- (void)drawRouteFromDriver:(CLLocationCoordinate2D)driverCoordinate toCoordinate:(CLLocationCoordinate2D)endCoordinate;
- (void)updateCameraZoomFromDriverLocation:(CLLocationCoordinate2D)driverCoord respectStartLocation:(CLLocationCoordinate2D)otherCoord;

- (void)showPins;

@end

#pragma mark Accessibility

@interface LocationViewController (Accessibility)

- (void)configureAccessibility;

@end

#pragma mark Car Categories

@interface LocationViewController (CarCategories)<RACategoryDataSource>

- (void)loadCategorySlider;
- (void)reloadCategories;

@end

#pragma mark - Split Fare

@interface LocationViewController (SplitFare)<SplitFarePushDelegate>

@end

#pragma mark - Idle Map Timer

@interface LocationViewController (IdleMapTimer)

- (void)disableAutoMoveAndZoom;
- (void)enableAutoMap;

@end




#pragma mark Rating

@interface LocationViewController (Rating)

- (void)loadCurrentUnratedRide;
- (void)addUnratedRide:(RARideDataModel*)ride;
- (void)showRatingViewForRide:(NSString *)rideID;

@end

#pragma mark Round up

@interface LocationViewController (RoundUp)

- (void)showRoundUpAlertIfNeeded;

@end

#pragma mark Place Search Delegate

@interface LocationViewController (PickerAddressDelegate)<PickerAddressDelegate>

@end

#pragma mark Textfield Delegate

@interface LocationViewController (UITextFieldDelegate)<UITextFieldDelegate>

@end

#pragma mark Reachability

@interface LocationViewController (Reachability) <RANotificationSlideDelegate>

- (void)addReachabilityObserver;
- (void)showOfflineMessageViewWithMessage:(NSString *)message;
- (void)closeOfflineMessageView:(id)sender;

@end

#pragma mark Notifications
#define kTimeToShowPermission 24 * 3600
#define kLastDatePermissionShownKey @"kLastDatePermissionShown"
@interface LocationViewController (Notifications)

- (void)configureObservers;
- (void)applicationWillEnterForeground:(NSNotification*)notification;
- (void)applicationDidEnterBackground:(NSNotification*)notification;

@end

#pragma mark Alerts

typedef void(^ConfirmationAlertBlock)(BOOL confirmed);

@interface LocationViewController (Alerts)

- (void)showConfirmationAlertWithHandler:(ConfirmationAlertBlock)handler;

@end

#pragma mark Estimate Fare Delegate

@interface LocationViewController (EstimatedFareViewDelegate) <EstimatedFareViewDelegate>

@end

#pragma mark Priority Fare (SurgeAreas)

typedef void(^SurgeAreaCompletion)(void);

@interface LocationViewController (PriorityFare)

- (void)processSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas withCompletion:(SurgeAreaCompletion)completion;

@end

#pragma mark Helpers

typedef void(^ConfirmedDistanceBlock)(BOOL confirmed);

@interface LocationViewController (Helpers)

- (void)validateStartAddressWithCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString*)address andVisibleAddress:(NSString*)visibleAddress zipCode:(NSString *)zipCode withCompletion:(void(^)(BOOL didSelectPlace))completion;
- (void)selectSource:(CLLocationCoordinate2D)coordinate address:(NSString*)address visibleAddress:(NSString*)visibleAddress isAvailable:(BOOL)available zipCode:(NSString *)zipCode;
- (void)selectDestination:(CLLocationCoordinate2D)coordinate address:(NSString*)address visibleAddress:(NSString*)visibleAddress zipCode:(NSString *)zipCode;
- (void)changeDestination;
- (void)checkSurgeAvailabilityForLocation:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)(NSError *error))handler;
- (void)resetAndGetActiveDrivers;
- (void)updatePaymentDeficiencyView;
- (void)deleteRideShowingAlert;
- (void)attemptToCancelRide;

- (void)processRequestRideAction;
- (void)processRequest;
- (void)requestRide;
- (void)handleCancelRideWithMessage:(NSString*)message;
- (UIEdgeInsets)insetsForMap;
- (BOOL)isFarLocation:(CLLocation*)location fromPickup:(CLLocation*)pickupLocation;
- (void)checkCurrentLocationDistanceToPickup:(CLLocation*)pickupLocation withHandler:(__nonnull ConfirmedDistanceBlock)handler;
- (void)showConfirmationRequestViewSavingPickUp:(BOOL)shouldSavePickup;
- (void)updateCurrentLocation:(CLLocationCoordinate2D)coordinate withAddress:(RAAddress*)address;
- (void(^)(NSError* _Nullable))currentLocationDefaultHandler;
- (void)moveToCurrentLocationWithCompletion:(void(^)(NSError*))completion;

@end

@interface LocationViewController (TTTAttributedLabelDelegate)<TTTAttributedLabelDelegate>

@end


#pragma mark - Components
@interface LocationViewController (RequestRideViewDelegate)<RequestRideViewDelegate>
@end
@interface LocationViewController (BottomDrawerViewDelegate)<BottomDrawerViewDelegate>
@end
@interface LocationViewController (DriverInfoViewDelegate)<DriverInfoViewDelegate>
@end

#pragma mark - Implementation
#pragma mark -

@implementation LocationViewController

#pragma mark  Custom Getters/Setters

- (RACarCategoryDataModel*)selectedCategory {
    return self.viewCategoryMainView.categorySlider.selectedCategory;
}

- (RARideRequest *)currentRideRequest {
    return [[RARideRequestManager sharedManager] currentRideRequest];
}

- (RARideDataModel *)currentRide {
    return [[RARideManager sharedManager] currentRide];
}

- (BOOL)isStartLocationSelected {
    return [self.currentRideRequest startLocation] != nil;
}

- (BOOL)isDestinationLocationSelected {
    return [self.currentRideRequest endLocation] != nil;
}

- (void)setCurrentUnratedRide:(NSString *)currentUnratedRide {
    _currentUnratedRide = currentUnratedRide;
    if (_currentUnratedRide != nil) {
        [self showRatingViewForRide:_currentUnratedRide];
    }
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeDefaultPropertiesValues];
    [self configureUI];
    [self configureRideManager];
    [self configureMapWithCurrrentLocation];
    [self configureAccessibility];
    [self showRoundUpAlertIfNeeded];
    [self configureObservers];
    [self addReachabilityObserver];
    [[PushNotificationSplitFareManager sharedManager] handleIfAppWasLaunchedByRemoteNotification];
    [self preLoadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.viewSetPickupLocation showLoadingAnimation];
    
    [self updatePaymentDeficiencyView];
    
    [self loadCategorySlider];
    
    if (self.viewSetPickupLocation.hidden == NO) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.viewSetPickupLocation.btnSetPickupLocation);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadCurrentUnratedRide];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.sideMenuCoordinator hideSideMenu];
    }
}

- (void)dealloc {
    DBLog(@"LocationVC Dealloc");
    [[RARideManager sharedManager] removeObserver:[self KVOController]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
    [self unobserveEvents];
}

#pragma mark - Initialize Properties

- (void)initializeDefaultPropertiesValues {
    self.currentActiveDriverETA = NSNotFound;
    self.isAutoMoveEnabled = YES;
    self.needsToResendDestinationChanged = NO;
    self.isSplitFareAlertDisplaying = NO;
    self.isOntripMarkersShown = NO;
    self.isDriverComingShown = NO;
    self.synchronizing = NO;
    self.retryingSynchronize = NO;
    self.needToPlayReachedSound = YES;
    self.settingSource = NO;
    self.riderChangedDestination = NO;
    self.recentPlaceMarginBottom = 16;
    self.shouldRefreshMap = YES;
    CLLocation *myLocation = [LocationService sharedService].myLocation;
    self.currentLocation = [[RARideLocationDataModel alloc] initWithLocation:myLocation];
}

#pragma mark - Configure Layout

- (void)configureUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureNavigationBar];
    [self configureContactButton];
    [self updateNavigationBarToDefault];
    [self configureViewSetPickupLocation];
    [self configureCategoryMainView];
    [self configureViewRequestRide];
    [self configureViewDriver];
    [self.view layoutIfNeeded];
    [self hideCommentsField];
#ifdef AUTOMATION
    self.pickUpCommentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
#endif
}

- (void)preLoadView {
    RARideStatus localStatus = self.currentRide ? self.currentRide.status : RARideStatusNone;
    if (!self.currentRide) {
        [[RARideRequestManager sharedManager] deleteRideRequest];
    }
    [self performRideStatusChangedTo:localStatus];
    [self synchronizeRideWithCompletion:nil];
    [[RASessionManager sharedManager] reloadCurrentRiderWithCompletion:nil];
}

- (void)loadDestinationFromSpotlightIfNeeded {
    if (!self.currentRide) {
        RAFavoritePlace *placeSelected = [RAPlaceSearchManager sharedInstance].placeSelected;
        if (placeSelected) {
            NSString *visibleAddress = placeSelected.name ?: placeSelected.shortAddress;
            visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:placeSelected.coordinate] ?: visibleAddress;
            [self selectDestination:placeSelected.coordinate address:placeSelected.shortAddress visibleAddress:visibleAddress zipCode:placeSelected.zipCode];
            [RAPlaceSearchManager sharedInstance].placeSelected = nil;
        }
    }
}

- (void)configureViewSetPickupLocation {
    self.viewSetPickupLocation = [[SetPickupLocationView alloc] initWithFrame:CGRectMake(0, 0, 280, 59) target:self action:@selector(didTapSetPickupButton:)];
    [self.view addSubview:self.viewSetPickupLocation];
    
    CGFloat offsetDueToPadding = - kGoogleMapInitialBottomPadding/2.0;
    
    [NSLayoutConstraint activateConstraints:
     @[
       [self.viewSetPickupLocation.heightAnchor constraintEqualToConstant:59],
       [self.viewSetPickupLocation.widthAnchor constraintEqualToConstant:280],
       [self.viewSetPickupLocation.centerYAnchor constraintEqualToAnchor:self.view.compatibleCenterYAnchor constant:offsetDueToPadding],
       [self.viewSetPickupLocation.centerXAnchor constraintEqualToAnchor:self.view.compatibleCenterXAnchor]
       ]];
}

- (void)configureCategoryMainView {
    self.viewCategoryMainView = [[BottomDrawerView alloc] initWithFlowController:self.mainCoordinator andDelegate:self];
    [self.view addSubview:self.viewCategoryMainView];
    self.bottomConstraintFareView = [self.view.bottomAnchor constraintEqualToAnchor:self.viewCategoryMainView.bottomAnchor constant:-256];
    [NSLayoutConstraint activateConstraints:
     @[
       self.bottomConstraintFareView,
       [self.viewCategoryMainView.leadingAnchor constraintEqualToAnchor:self.view.compatibleLeadingAnchor],
       [self.viewCategoryMainView.trailingAnchor constraintEqualToAnchor:self.view.compatibleTrailingAnchor]
       ]];
}

- (void)configureViewRequestRide {
    self.viewRequestRide = [[RequestRideView alloc] initWithFlowController:self.mainCoordinator rideRequestManager:[RARideRequestManager sharedManager] andDelegate:self];
    [self.view addSubview:self.viewRequestRide];
    
    [NSLayoutConstraint activateConstraints:
     @[
       [self.viewRequestRide.leadingAnchor constraintEqualToAnchor:self.view.compatibleLeadingAnchor constant:kMainMargin],
       [self.view.compatibleTrailingAnchor constraintEqualToAnchor:self.viewRequestRide.trailingAnchor constant:kMainMargin],
       [self.view.compatibleBottomAnchor constraintEqualToAnchor:self.viewRequestRide.bottomAnchor constant:kMainMarginBottom]
       ]];
}

- (void)configureViewDriver {
    self.viewDriver = [[DriverInfoView alloc] initWithFrame:CGRectZero flowController:self.mainCoordinator andDelegate:self];
    [self.view addSubview:self.viewDriver];
    self.constraintViewDriverTopToSuperViewBottom = [self.viewDriver.topAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-self.viewDriver.visibleHeightCollapsed];
    [NSLayoutConstraint activateConstraints:
     @[
       self.constraintViewDriverTopToSuperViewBottom,
       [self.viewDriver.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
       [self.viewDriver.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
       ]];
}

- (void)configureNavigationBar {
    UIBarButtonItem *menu = [UIBarButtonItem defaultImageName:@"menu-icon" target:self action:@selector(didTapMenuBarButton:)];
    menu.accessibilityLabel = @"show menu".localized;
    menu.accessibilityHint  = @"You can see your payment history, round up, promotions or settings".localized;
    
    self.btFindLocation = [UIBarButtonItem defaultImageName:@"find-current-location-icon" target:self action:@selector(didTapFindLocationBarButton:)];
    self.btFindLocation.accessibilityLabel = @"show my location".localized;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.rightBarButtonItem = self.btFindLocation;
    self.navigationItem.leftBarButtonItem  = menu;
}

- (void)configureContactButton {
    CGFloat width = [UIScreen mainScreen].bounds.size.width <= 320 ? 68 : 80;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 28)];
    btn.titleLabel.font = [UIFont fontWithName:FontTypeRegular size:12];
    btn.layer.cornerRadius = 14;
    btn.layer.borderColor = [UIColor colorWithHex:@"#DFDFDF"].CGColor;
    btn.layer.borderWidth = 1;
    [btn setTitle:[@"Contact" localized].uppercaseString forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHex:@"#2C323C"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didTapContactDriver:) forControlEvents:UIControlEventTouchUpInside];
    self.btContact = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (IBAction)didTapAddressButton:(RAAddressButton *)sender {
    [self attemptToShowPickerWithText:sender.text andType:sender.fieldType];
}

- (void)attemptToShowPickerWithText:(NSString *)currentAddressText andType:(RAPickerAddressFieldType)pickerAddressFieldType {
    //Doesn't allow editing Pickup if rider in a ride
    if (pickerAddressFieldType == RAPickerAddressPickupFieldType && [[RARideManager sharedManager] isRiding]) {
        return;
    }
    
    PickerAddressViewController *pickerAddressViewController = [[PickerAddressViewController alloc] initWithDelegate:self addressFieldType:pickerAddressFieldType previousAddress:currentAddressText andMapView:self.googleMapView];
    [self.navigationController pushViewController:pickerAddressViewController animated:YES];
}

@end

#pragma mark - User Interaction

@implementation LocationViewController (UserInteraction)

- (void)didTapMenuBarButton:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self trackButtonUI:@"Menu"];
    [self.sideMenuCoordinator showSideMenu];
}

- (void)didTapFindLocationBarButton:(UIBarButtonItem *)sender {
    //RA-9673. Avoid changing anything if it is setting source.
    if ([self isSettingSource]) {
        return;
    }
    
    self.btFindLocation.enabled = NO;
    [self trackButtonUI:@"Find Location"];
    [self moveToCurrentLocationWithCompletion:[self currentLocationDefaultHandler]];
}

- (void)didTapSetPickupButton:(UIButton *)sender {
    self.shouldRefreshMap = NO;
    
    if ([self isUserActive] == NO) {
        return ;
    }
    
    if (self.isPaymentMethodValid == NO) {
        [self.mainCoordinator navigateToPaymentMethodList];
        return;
    }
    
    CLLocation *startLocation = self.currentLocation.location;
    if (startLocation.isValid == NO) {
        [RAAlertManager showAlertWithTitle:[@"Invalid" localized] message:[@"Location is invalid." localized]];
        return;
    }
    
    [self collapseViewCategoryMainView];
    __weak __typeof__(self) weakself = self;
    [self checkCurrentLocationDistanceToPickup:startLocation withHandler:^(BOOL confirmed) {
        if (confirmed) {
            [weakself showConfirmationRequestViewSavingPickUp:sender != nil];
        }
    }];
}

- (BOOL)isUserActive {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    if (rider.user.active == NO) {
        NSString * message = [NSString  stringWithFormat:@"Your account is not yet active. Please contact %@",[ConfigurationManager shared].global.generalInfo.supportEmail];
        [RAAlertManager showAlertWithTitle:NSString.accessibleAlertTitleRideAustin message:[message localized]];
        return NO;
    }
    return YES;
}
- (BOOL)isPaymentMethodValid {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    
    if (rider.unpaidBalance) {
        return NO;
    }
    
    BOOL isUsingApplePay = [ApplePayHelper hasApplePaySetup] && rider.preferredPaymentMethod == PaymentMethodApplePay;
    if (!isUsingApplePay) {
        if (!rider.hasPrimaryCard) {
            return NO;
        }
        if (rider.hasPrimaryCard && rider.primaryCard.cardExpired.boolValue) {
            return NO;
        }
    }
    
    return YES;
}

- (void)showCancellationAlertWithLine1:(NSString *)line1 line2:(NSString *)line2 line3:(NSString *)line3 {
    __weak LocationViewController *weakSelf = self;
    self.tripCancellationAlert = [RAAlertView alertViewWithTitle:[@"CANCEL TRIP" localized] line1:line1 line2:line2 line3:line3 completion:^(BOOL yesPressed) {
        weakSelf.rideCancellationTimer = nil;
        if (yesPressed) {
            [weakSelf attemptToCancelRide];
        }
        weakSelf.tripCancellationAlert = nil;
    }];

    //work around for issue where long line1 is truncated on creation
    [self.tripCancellationAlert updateLine1:line1];
    
    self.tripCancellationAlert.accessibilityIdentifier = @"rideCancellationAlert";
    [self.tripCancellationAlert show];
}

- (void)setupTripCancellationTimer {
    __weak LocationViewController *weakSelf = self;
    self.rideCancellationTimer = [[RARideCancellationTimer alloc] initWithDispatchBlock:^{
        NSTimeInterval remainingTime = weakSelf.currentRide.freeCancellationExpiryDate.timeIntervalSinceNow;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (remainingTime > 0) {
                [weakSelf.tripCancellationAlert updateLine1:[NSString stringWithFormat:[@"You have %lu seconds to cancel the ride without being charged. After that you will be charged" localized],(long)remainingTime]];
            } else {
                [weakSelf.tripCancellationAlert updateLine1:[@"You will be charged" localized]];
                weakSelf.rideCancellationTimer = nil;
            }
        });
    }];
    [self.rideCancellationTimer resume];
}

- (void)didTapContactDriver:(UIButton *)sender {
    RARideDataModel *ride = [RARideManager sharedManager].currentRide;
    [self.mainCoordinator navigateToContactDriver:ride.activeDriver.driver sender:sender];
}

- (BOOL)isPreselectedSourceValid {
    return [self.preselectedSource.location isValid] && self.btPickupAddress.text.length > 0;
}

- (BOOL)isPreselectedDestinationValid {
    return [self.preselectedDestination.location isValid] && self.btDestinationAddress.text.length > 0;
}

- (BOOL)isSourceAddressValid {
    return [self.currentRideRequest.startLocation.location isValid] && self.btPickupAddress.text.length > 0;
}

- (BOOL)isDestinationAddressValid {
    return [self.currentRideRequest.endLocation.location isValid] && self.btDestinationAddress.text.length > 0;
}

#pragma mark - IBActions

- (void)didTapFareEstimate:(UIButton *)sender {
    CLLocationCoordinate2D startCoord = kCLLocationCoordinate2DInvalid;
    CLLocationCoordinate2D endCoord = kCLLocationCoordinate2DInvalid;
    
    if ([[RARideManager sharedManager] isRiding]) {
        RARideDataModel *currentRide = [RARideManager sharedManager].currentRide;
        startCoord = currentRide.startCoordinate;
        endCoord = currentRide.endCoordinate;
    } else {
        BOOL selectedSourceIsValid = [self isSourceAddressValid];
        BOOL selectedDestinationIsValid = [self isDestinationAddressValid];
        BOOL preselectedSourceIsValid = [self isPreselectedSourceValid];
        BOOL preselectedDestinationIsValid = [self isPreselectedDestinationValid];
        
        if (selectedSourceIsValid) {
            startCoord = self.currentRideRequest.startLocation.coordinate;
        } else if (preselectedSourceIsValid) {
            startCoord = self.preselectedSource.coordinate;
        }
        
        if (selectedDestinationIsValid) {
            endCoord = self.currentRideRequest.endLocation.coordinate;
        } else if (preselectedDestinationIsValid) {
            endCoord = self.preselectedDestination.coordinate;
        }
    }
    
    BOOL startCoordIsValid = [CLLocation isCoordinateNonZero:startCoord];
    BOOL endCoordIsValid = [CLLocation isCoordinateNonZero:endCoord];
    
    if (startCoordIsValid && endCoordIsValid) {
        __weak __typeof__(self) weakself = self;
        [self showHUD];
        [RARideAPI getRideEstimateFromStartLocation:startCoord
                                      toEndLocation:endCoord
                                         inCategory:self.selectedCategory
                                     withCompletion:^(RAEstimate *estimate, NSError *error) {
                                         [weakself hideHUD];
                                         sender.enabled = YES;
                                         if (!error) {
                                             EstimatedFareViewController *estimateVC = [EstimatedFareViewController new];
                                             estimateVC.delegate = weakself;
                                             estimateVC.viewModel = [[RAEstimatedFareViewModel alloc] initWithStartAddress:weakself.btPickupAddress.text endAddress:weakself.btDestinationAddress.text estimate:estimate];
                                             
                                             UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:estimateVC];
                                             [weakself.navigationController presentViewController:nav animated:YES completion:nil];
                                         } else {
                                             [weakself.mainCoordinator navigateToError:error];
                                         }
                                     }];
    } else {
        NSString *message = [@"Please select a destination location to get estimates." localized];
        if (!startCoordIsValid) {
            message = [@"Please select a pickup location to get estimates." localized];
        }
        [RAAlertManager showAlertWithTitle:NSString.accessibleAlertTitleRideAustin message:message];
        sender.enabled = YES;
    }
}

#pragma mark - RoundUp

- (IBAction)btnYesRoundUpPressed:(UIButton *)sender {
    [_popupRoundUpAlert dismiss:YES];
    [self.mainCoordinator navigateToRoundUp];
}

- (IBAction)btnNoRoundUpPressed:(UIButton *)sender {
    [_popupRoundUpAlert dismiss:YES];
    [PersistenceManager increaseCancelRoundUpPopupCount];
}

#pragma mark -

- (IBAction)btnCloseRequestPressed:(id)sender {
    [self deleteRideShowingAlert];
}



@end

#pragma mark - Ride Polling
#pragma mark - RidePolling Configuration

@implementation LocationViewController (RidePollingConfiguration)

- (void)configureRideManager {
    [[RARideManager sharedManager] setPollingConsumerDelegate:self];
}

@end

#pragma mark RidePollingConsumer Delegate

@implementation LocationViewController (RidePollingconsumerDelegate)

- (void)pollingNeedsSynchronization {
    [self synchronizeRideWithCompletion:nil];
}

@end

#pragma mark - Ride engine

@implementation LocationViewController (RideEngine)

- (void)checkAppUpgrade:(AppUpgradeCompletionBlock)completion {
    [[RAUpgradeManager sharedManager] verifyUpgradeWithCompletion:^(BOOL shouldUpgrade, BOOL isMandatory, NSError *error) {
        if (completion) {
            completion(shouldUpgrade, isMandatory);
        }
    }];
}

- (void)synchronizeRideWithCompletion:(void (^)(void))handler {
    if (![self isSynchronizing] && [[RASessionManager sharedManager] isSignedIn]) {
        self.synchronizing = YES;
        
        __weak LocationViewController *weakSelf = self;
        void(^processSynchronizedRide)(RARideDataModel *ride, NSError *error) = ^(RARideDataModel *ride, NSError *error) {
            if (ride) {
                [weakSelf handleSynchronizedRide:ride withCompletion:handler];
            } else if (!error) {
                [weakSelf handleSynchronizedNoneRideWithCompletion:handler];
            } else {
                [weakSelf handleSynchronizationError:error withCompletion:handler];
            }
        };
        
        BFLog(@"Synchronizing ride");
        [[RARideManager sharedManager] reloadRideWithCompletion:^(RARideDataModel *ride, NSError *error) {
            if (![[RARideManager sharedManager] isRiding]) {
                [weakSelf checkAppUpgrade:^(BOOL shouldUpgrade, BOOL isMandatory) {
                    processSynchronizedRide(ride, error);
                }];
            } else {
                processSynchronizedRide(ride, error);
            }
        }];
        
    } else {
        if (handler) {
            handler();
        }
    }
}

- (void)handleSynchronizedRide:(RARideDataModel *)ride withCompletion:(void(^)(void))handler {
    BFLog(@"Ride %@", ride);
    [[RARideRequestManager sharedManager] reloadCurrentRideRequestWithPickupLocation:[ride.startLocation copy] andDestinationLocation:[ride.endLocation copy]];
    [self performRideStatusChangedTo:ride.status];
    
    [[RAUpgradeRequestManager sharedManager] showOrHidePopUpForUpgradeRequest:self.currentRide.upgradeRequest andRide:ride.modelID.stringValue];
    [self.viewCategoryMainView.categorySlider moveToCategory:self.currentRide.requestedCarType.title];
    [self showOrHideStackedRideViewBasedOnPrecedingRide];
    
    self.retryingSynchronize = NO;
    self.synchronizing = NO;
    
    if (handler) {
        handler();
    }
}

- (void)handleSynchronizedNoneRideWithCompletion:(void(^)(void))handler {
    BFLog(@"There was no error either ride.");
    if (![self currentRideRequest]) {
        BFLog(@"There isn't a current ride request");
        [self performRideStatusChangedTo:RARideStatusNone];
        self.retryingSynchronize = NO;
        self.synchronizing = NO;
        
        if (handler) {
            handler();
        }
        return;
    }
    
    BFLog(@"There is a current ride request %@", self.currentRideRequest);
    UIViewController *presentedVC = self.presentedViewController;
    if (presentedVC && [presentedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)presentedVC;
        if ([[nav topViewController] isKindOfClass:[PriorityFareConfirmationViewController class]]) {
            [self performRideStatusChangedTo:RARideStatusRequesting];
        } else {
            [self performRideStatusChangedTo:RARideStatusPrepared];
        }
    } else {
        [self performRideStatusChangedTo:RARideStatusPrepared];
    }
    
    RARideRequest *currentRequest = self.currentRideRequest;
    if (currentRequest.startLocation) {
        self.currentLocation = currentRequest.startLocation;
        __weak LocationViewController *weakself = self;
        [self checkSurgeAvailabilityForLocation:self.currentLocation.coordinate withCompletion:^(NSError *error) {
            weakself.retryingSynchronize = NO;
            weakself.synchronizing = NO;
            
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            }
            
            if (handler) {
                handler();
            }
        }];
    } else {
        self.retryingSynchronize = NO;
        self.synchronizing = NO;
        
        if (handler) {
            handler();
        }
    }
}

- (void)handleSynchronizationError:(NSError *)error withCompletion:(void(^)(void))handler {
    BFLogErr(@"Error %@", error);
    if ([error.domain isEqualToString:kNeedCompleteRideErrorDomain]) { //internet is off during ride and ride is completed before connected again.
        [self performRideStatusChangedTo:self.currentRide.status];
        [[RARideManager sharedManager] removeCurrentRide]; //this error occurs when a ride have been completed, so the status of the ride can only be "COMPLETED", "DRIVER_CANCELLED" and "ADMIN_CANCELLED"; ("RIDER_CANCELLED" could be if cancelled from another device). So it is ok to delete the current ride.
        self.retryingSynchronize = NO;
        
    } else if (error.code == 401 || error.code == 404) {
        [[RARideManager sharedManager] removeCurrentRide];
        [self performRideStatusChangedTo:RARideStatusNone];
        self.retryingSynchronize = NO;
        
    } else {
        if (!self.retryingSynchronize) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
        
        self.retryingSynchronize = YES;
        [self performSelector:@selector(synchronizeRideWithCompletion:) withObject:nil afterDelay:2];
    }
    
    self.synchronizing = NO;
    if (handler) {
        handler();
    }
}


- (void)performChangesOnRide:(NSDictionary *)changes {
    
    NSString *keyPath = changes[kRAObservationKeyPath];
    id valueOld = changes[kRAObservationOldValue];
    id valueNew = changes[kRAObservationNewValue];
    
    //Ride status change
    if ([keyPath isEqualToString:kRAKeyPathObserveCurrentRideStatus]) {
        if ([valueNew isKindOfClass:[NSNumber class]]) {
            RARideStatus rideStatus = [valueNew integerValue];
            [self performRideStatusChangedTo:rideStatus];
        }
    }
    else if ([keyPath isEqualToString:kRAKeyPathObserveEstimatedCompletionDate]) {
        [self updateEstimatedCompletionTime];
    }
    //Preceding Ride Status
    else if ([keyPath isEqualToString:kRAKeyPathObservePrecedingRideStatus]) {
        NSNumber *precedingRideStatusOld = valueOld;
        if ([precedingRideStatusOld isKindOfClass:NSNumber.class]) {
            RARideStatus rideStatusOld = precedingRideStatusOld.integerValue;
            NSNumber *precedingRideStatusNew = valueNew;
            if (rideStatusOld == RARideStatusActive) {
                if ([precedingRideStatusNew isKindOfClass:NSNull.class] || ([precedingRideStatusNew isKindOfClass:NSNumber.class] && precedingRideStatusNew.integerValue == RARideStatusCompleted)) {
                    if (self.tripCancellationAlert.isVisible) {
                        __weak __typeof__(self) weakself = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                           [weakself.tripCancellationAlert dismiss];
                        });
                    }
                }
            }
        }
        [self showOrHideStackedRideViewBasedOnPrecedingRide];
    }
    //Preceding Ride Destination
    else if ([keyPath isEqualToString:kRAKeyPathObservePrecedingRideEndLocation]) {
        [self updatePrecedingRideMarker];
    }
    //Destination location change
    else if ([keyPath isEqualToString:kRAKeyPathObserveCurrentRideEndLocation]) {
        
        if ([valueNew isKindOfClass:[CLLocation class]]) {
            CLLocationCoordinate2D endLocationNew = ((CLLocation*)valueNew).coordinate;
            CLLocationCoordinate2D endLocationOld = [valueOld isKindOfClass:[CLLocation class]] ? ((CLLocation*)valueOld).coordinate : kCLLocationCoordinate2DInvalid;
            
            RARideStatus nextRideStatus = [[[RARideManager sharedManager] currentRide] nextStatus];
            RARideLocationDataModel *destination = [[[RARideManager sharedManager] currentRide] endLocation];
            
            NSString *addressEnd = [RAFavoritePlacesManager visibleAddressForCoordinate:destination.coordinate];

            if (!addressEnd) {
                addressEnd = destination.address;
            }
            
            self.btDestinationAddress.text = [self.currentRideRequest endLocation].visibleAddress ?: addressEnd;
            [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:destination.coordinate];
            if (nextRideStatus == RARideStatusActive) {
                CLLocation *driverLocation = self.currentRide.activeDriver.location;
                
                [self drawRouteFromDriver:driverLocation.coordinate
                             toCoordinate:destination.location.coordinate];
            }
            else {
                [self.googleMapsManager animateCameraToFitStartCoordinate:destination.coordinate endCoordinate:self.currentRide.startLocation.coordinate withEdgeInsets:self.insetsForMap];
            }

            CLLocationCoordinate2D endLocationStored = [[[[RARideRequestManager sharedManager] currentRideRequest] endLocation] coordinate];
            if ([[RARideManager sharedManager] isRiding:nextRideStatus] && ![RARideManager rideCoordinate:endLocationNew isEqualToOtherRideCoordinate:endLocationOld] && ![RARideManager rideCoordinate:endLocationNew isEqualToOtherRideCoordinate:endLocationStored] && !self.riderChangedDestination) {
                
                self.riderChangedDestination = NO;
                [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:[NSString stringWithFormat:[@"Destination has been changed to \"%@\"" localized],addressEnd] options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
            }
        }
    }
    //Polling error change
    else if ([keyPath isEqualToString:kRAKeyPathObservePollingError]) {
        
        NSError *pollingError = valueNew;
        if ([pollingError isKindOfClass:NSError.class]) {
            if (pollingError && ![pollingError.localizedDescription isEqualToString:@"The request timed out."]) {
                [RAAlertManager showErrorWithAlertItem:pollingError andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AvoidRecurring]];
            }
        }
    }
    //Active driver location change
    else if ([keyPath isEqualToString:kRAKeyPathObserveActiveDriverLocation]) {
        CLLocation *driverLocation = valueNew;
        if ([driverLocation isKindOfClass:[CLLocation class]]) {
            [self updateActiveDriverLocation:driverLocation];
        }
    }
    //Upgrade Request
    else if([keyPath isEqualToString:kRAKeyPathObserveUpgradeRequest] || [keyPath isEqualToString:kRAKeyPathObserveUpgradeRequestStatus]) {
        [[RAUpgradeRequestManager sharedManager] showOrHidePopUpForUpgradeRequest:self.currentRide.upgradeRequest andRide:self.currentRide.modelID.stringValue];
    }
    else if ([keyPath isEqualToString:kRAKeyPathObserveRequestedCarTypeTitle]) {
        [self.viewCategoryMainView.categorySlider moveToCategory:self.currentRide.requestedCarType.title];
        [self updateDriverInfoAndUpdateTimers:NO];
    }
}

- (void)rideManager:(RARideManager *)rideManager didChangeStatus:(RARideStatus)rideStatus {
    [[LocationService sharedService] updateLocationSettingsForStatus:rideStatus];
    [RAUpgradeRequestManager didChangeRideStatus:rideStatus];
    switch (rideStatus) {
        case RARideStatusUnknown:
            BFLog(@"Status changed to unknown");
            [RAAlertManager showAlertWithTitle:[@"GENERIC_ERROR_TITLE" localized] message:[@"VERSION_OUTDATED" localized]];
            [ErrorReporter recordErrorDomainName:WATCHUnknownRideStatus withUserInfo:@{@"RideId":self.currentRide.modelID.stringValue ?: @"nil"}];
            break;
        case RARideStatusNone:
            BFLog(@"Status changed to None");
            
            self.isLocationSelectedFromValidSource = NO;
            self.shouldRefreshMap = YES;
            [self.googleMapsManager showMyLocation:YES];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            break;
            
        case RARideStatusPrepared:
            BFLog(@"Status changed to Prepared");
            
            [self.googleMapsManager showMyLocation:YES];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            break;
            
        case RARideStatusRequesting:
            BFLog(@"Status changed to Requesting");
            [self.googleMapsManager showMyLocation:YES];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            break;
            
        case RARideStatusRequested:
            BFLog(@"Status changed to Requested");
            self.isDriverComingShown = NO;
            
            [self.googleMapsManager showMyLocation:YES];

            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            break;
            
        case RARideStatusNoAvailableDriver:{
            BFLog(@"Status changed to NoAvailableDriver");
            
            [self.googleMapsManager showMyLocation:YES];
            
            // there may not be any drivers in range, or there are drivers but no driver accepted the ride (RA-286)
            NSString *title = [@"No Driver Available" localized];
            NSString *message = [@"We are sorry currently no driver is available at your location." localized];
            if (self.googleMapsManager.currentNearbyCarsIdentifier.count > 0) {
                message = [@"No drivers available right now, please try again later." localized];
            }
            
            [RAAlertManager showAlertWithTitle:title
                                       message:message
                                       options:[RAAlertOption optionWithShownOption:Overlap]];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            break;
        }
        case RARideStatusRiderCancelled:{
            BFLog(@"Status changed to RiderCancelled");
            [[RARideRequestManager sharedManager] deleteRideRequest];
            
            self.preselectedDestination = nil;
            self.preselectedComment = nil;

            self.shouldRefreshMap = YES;
            
            [self.googleMapsManager showMyLocation:YES];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];
            
            [self checkAppUpgrade:nil];
            
            break;
        }
        case RARideStatusDriverCancelled:{
            BFLog(@"Status changed to DriverCancelled");

            NSString *cancellationMessage = [@"Your ride is cancelled by the driver." localized];
            double fareCharged = [[[[RARideManager sharedManager] currentRide] totalFare] doubleValue];
            if (fareCharged > 0.0) {
                cancellationMessage = [NSString stringWithFormat:[@"Your ride has been cancelled by the driver. You've been charged a $%.2f cancellation fee for no show." localized], fareCharged];
            }
            
            [[RARideRequestManager sharedManager] deleteRideRequest];
            
            self.preselectedDestination = nil;
            self.preselectedComment = nil;
            
            self.shouldRefreshMap = YES;

            [self.googleMapsManager showMyLocation:YES];

            [self handleCancelRideWithMessage:cancellationMessage];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];

            [self checkAppUpgrade:nil];

            break;
        }
        case RARideStatusAdminCancelled:{
            BFLog(@"Status changed to AdminCancelled");
            [[RARideRequestManager sharedManager] deleteRideRequest];
            
            self.preselectedDestination = nil;
            self.preselectedComment = nil;

            self.shouldRefreshMap = YES;

            [self.googleMapsManager showMyLocation:YES];

            [self handleCancelRideWithMessage:[@"Your ride is cancelled by admin." localized]];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];

            [self checkAppUpgrade:nil];

            break;
        }
        case RARideStatusDriverAssigned:
            BFLog(@"Status changed to DriverAssigned");
            
            [self.googleMapsManager showMyLocation:NO];
            
            [self stopPollingForActiveDrivers];
            [[SplitFareManager sharedManager] startPolling];

            break;
        case RARideStatusDriverReached:
            BFLog(@"Status changed to DriverReached");
            
            if (self.needToPlayReachedSound) {
                self.needToPlayReachedSound = NO;
                AudioServicesPlaySystemSound(1005);
            }
            
            [self.googleMapsManager showMyLocation:NO];

            [self stopPollingForActiveDrivers];
            [[SplitFareManager sharedManager] startPolling];

            break;
            
        case RARideStatusActive:
            BFLog(@"Status changed to Active");
            
            [self.googleMapsManager showMyLocation:NO];

            [self stopPollingForActiveDrivers];
            [[SplitFareManager sharedManager] startPolling];
            
            break;
            
        case RARideStatusCompleted:{
            BFLog(@"Status changed to Completed");
            RARideDataModel *ride = [RARideManager sharedManager].currentRide;
            if (ride.modelID) {
                #ifdef TEST
                #else
                [FBSDKAppEvents logEvent: @"COMPLETED" parameters: @{ @"rideId": ride.modelID }];
                #endif
            }
            [[RARideRequestManager sharedManager] deleteRideRequest];
            
            self.preselectedDestination = nil;
            self.preselectedComment = nil;

            self.shouldRefreshMap = YES;
            
            [self.googleMapsManager showMyLocation:YES];
            
            [self addUnratedRide: ride];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];

            [self checkAppUpgrade:nil];
        
            break;
        }
        default:
            BFLog(@"Status changed to unknown ~ default case");
            [[RARideRequestManager sharedManager] deleteRideRequest];
            
            self.preselectedDestination = nil;
            self.preselectedComment = nil;

            [self.googleMapsManager showMyLocation:YES];
            
            [self startPollingForActiveDrivers];
            [[SplitFareManager sharedManager] stopPolling];

            break;
    }
    
    if (rideStatus != RARideStatusDriverReached) {
        self.needToPlayReachedSound = YES;
    }
    
    [self updateUIWithRideStatus:rideStatus];
}

@end

@implementation LocationViewController (RideEnginePublic)

- (void)performRideStatusChangedTo:(RARideStatus)rideStatus {
    [RARideManager sharedManager].status = rideStatus;
    [self rideManager:[RARideManager sharedManager] didChangeStatus:rideStatus];
}

@end

#pragma mark - UIUpdates

static NSString* const kActiveRouteIdentifier = @"kActiveRouteIdentifier";

#define krateSubmitEnabledColor [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1]

@implementation LocationViewController (UIUpdates)

- (void)createNavigationTitleView {
    UIImageView *imgLogo = [[UIImageView alloc] initWithImage:[AssetCityManager logoImageCurrentCity]];
    if ([RAEnvironmentManager sharedManager].environment == RAQAEnvironment) {
        imgLogo.accessibilityIdentifier = @"locationCityLogo";
    }
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110.0, 30.0)];
    [imgLogo setFrame:titleView.bounds];
    [titleView addSubview:imgLogo];
    self.title = nil;
    self.navigationItem.titleView = titleView;
    self.navigationController.navigationBar.accessibilityIdentifier = self.navigationBarName;
}

- (void)updateNavigationBarToDefault {
    [self createNavigationTitleView];
    self.navigationItem.titleView.accessibilityLabel = nil;
}

- (void)updateNavigationBarToTripStarted {
    [self createNavigationTitleView];
    self.navigationItem.titleView.accessibilityLabel = @"Trip Started";
}

- (void)updateNavigationTitle:(NSString*)title {
    self.navigationItem.titleView = nil;
    self.title = title;
}

- (void)updateUIWithRideStatus:(RARideStatus)status {
    [self showOrHideStackedRideViewBasedOnPrecedingRide];
    switch (status) {
        case RARideStatusUnknown:
            // Do nothing
            break;
        case  RARideStatusNone:
            [self updateViewToState:RALocationViewStateInitial];
            break;
        case RARideStatusPrepared:
            [self updateViewToState:RALocationViewStatePrepared];
            break;
        case RARideStatusRequesting:
            [self updateViewToState:RALocationViewStateRequesting];
            break;
        case RARideStatusRequested:
            [self updateViewToState:RALocationViewStateRideAssigned];
            break;
        case RARideStatusNoAvailableDriver:
            [self updateViewToState:RALocationViewStatePrepared];
            break;
        case RARideStatusRiderCancelled:
        case RARideStatusDriverCancelled:
        case RARideStatusAdminCancelled:
            [self updateViewToState:RALocationViewStateTripCanceled];
            break;
        case RARideStatusDriverAssigned:
            [self updateViewToState:RALocationViewStateWaitingDriver];
            break;
        case RARideStatusDriverReached:
            [self updateViewToState:RALocationViewStateDriverReached];
            break;
        case RARideStatusActive:
            [self updateViewToState:RALocationViewStateTripStarted];
            break;
        case RARideStatusCompleted:
            [self updateViewToState:RALocationViewStateRating];
            break;
            
        default:
            [self updateViewToState:RALocationViewStateInitial];
            break;
    }
}

- (void)updateViewToState:(RALocationViewState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewCategoryMainView updateVisibilityBasedOnState:state];
        [self updateNavigationBarWithState:state];
        switch (state) {
            case RALocationViewStateClear:
                [self setViewToStateClear];
                break;
            case RALocationViewStateInitial:
                [self setViewToStateInitial];
                break;
            case RALocationViewStatePrepared:
                [self setViewToStatePrepared];
                break;
            case RALocationViewStateRequesting:
                [self setViewToStateRequesting];
                break;
            case RALocationViewStateRideAssigned:
                [self setViewToStateRideAssigned];
                break;
            case RALocationViewStateWaitingDriver:
                [self setViewToStateWaitingDriver];
                break;
            case RALocationViewStateDriverReached:
                [self setViewToStateDriverReached];
                break;
            case RALocationViewStateTripStarted:
                [self setViewToStateTripStarted];
                break;
            case RALocationViewStateTripCanceled:
            case RALocationViewStateRating:
                [self setViewToStateRideCleanup];
                break;
        }
    });
}

- (void)setViewToStateClear {
    DBLog(@"set view Clear");
    [self.googleMapsManager removeTripMarkers];
    
    [self showBothFields];
    
    [self updateNavigationBarToDefault];
    
    [self hideRequestingView:YES];
    [self hideCancelRequestingButton:YES];

    [self.viewRequestRide setHidden:YES];
    [self.viewDriver updateBasedOnRide:self.currentRide];
    
    [self.viewSetPickupLocation setHidden:NO];
    
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    
    [self loadDestinationFromSpotlightIfNeeded];
    [self.btnETADestination setHidden:YES];
}

- (void)setViewToStateInitial {
    [self setViewToStateClear];
    BFLog(@"set view Initial");
    
    if (self.shouldRefreshMap) {
        [self moveToCurrentLocationWithCompletion:[self currentLocationDefaultHandler]];
    }
}

- (void)setViewToStatePrepared {
    BFLog(@"set view Prepared");
    [self updateNavigationTitle:[@"Confirmation" localized]];

    [self.googleMapsManager eraseRouteWithIdentifier:kActiveRouteIdentifier];
    
    [self.viewSetPickupLocation setHidden:YES];

    self.pickUpCommentTextField.text = self.currentRideRequest.cachedComment;
    
    [self showBothFields];
    [self showCommentsField];
    
    [self hideRequestingView:YES];
    [self hideCancelRequestingButton:YES];
    
    [self.googleMapsManager removePickupTimeMarker];
    [self.googleMapsManager removeDriverMarker];
    
    [self.viewDriver updateBasedOnRide:self.currentRide];
    [self.viewRequestRide setHidden:NO];
    [self.viewRequestRide updateButtonCategoryTitle:self.selectedCategory.title];
    [self.viewRequestRide updateRequestType:nil];
    
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    
    [self updateAddressesAndPinsAnimated:YES];
    
    [self loadDestinationFromSpotlightIfNeeded];
    [self.btnETADestination setHidden:YES];
}

- (void)updateAddressesAndPinsAnimated:(BOOL)animated {
    RARideRequest *currentRequest = self.currentRideRequest;
    
    RARideLocationDataModel *pickUpLocation = [currentRequest startLocation];
    if (pickUpLocation) {
        self.btPickupAddress.text = pickUpLocation.visibleAddress;
        [self.googleMapsManager createOrUpdatePickupMarkerWithCoordinate:pickUpLocation.coordinate];
    }
    
    NSString *pickUpComment = currentRequest.comment;
    if (pickUpComment) {
        self.pickUpCommentTextField.text = pickUpComment;
    }
    
    RARideLocationDataModel *destinationLocation = [currentRequest endLocation];
    if (destinationLocation) {
        self.btDestinationAddress.text = destinationLocation.visibleAddress;
        [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:destinationLocation.coordinate];
    }
    
    if (animated) {
        if (pickUpLocation && destinationLocation) {
            [self showPins];
        } else if (pickUpLocation) {
            [self.googleMapsManager animateCameraToCoordinate:pickUpLocation.coordinate];
        }
    }
}

- (void)setViewToStateRequesting {
    BFLog(@"set view Requesting");
    [self updateNavigationTitle:[@"Requesting" localized]];
    
    [self.googleMapsManager removePickupTimeMarker];
    [self.googleMapsManager removeDriverMarker];
    
    [self updateAddressesAndPinsAnimated:NO];
    
    [self.googleMapsManager eraseRouteWithIdentifier:kActiveRouteIdentifier];

    [self.viewSetPickupLocation setHidden:YES];

    [self.viewRequestRide setHidden:YES];
    
    [self hideRequestingView:NO];
    [self hideCancelRequestingButton:YES];
    
    [self hideAddressFields];
    [self hideCommentsField];
    
    [self.viewDriver updateBasedOnRide:nil];
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    
    [self.btnETADestination setHidden:YES];
}

- (void)setViewToStateRideAssigned {
    [self setViewToStateRequesting];
    BFLog(@"set view Ride Assigned");
    [self hideCancelRequestingButton:NO];
}

- (void)setViewToStateWaitingDriver {
    BFLog(@"set view Waiting Driver");
    [self updateNavigationTitle:[@"Driver on way" localized]];
    
    RARideDataModel *ride = self.currentRide;
    self.btPickupAddress.text = [self.currentRideRequest startLocation].visibleAddress ?: ride.startLocation.visibleAddress;
    self.btDestinationAddress.text = [self.currentRideRequest endLocation].visibleAddress ?: ride.endLocation.visibleAddress;
    self.pickUpCommentTextField.text = ride.comment;
    
    [self showBothFields];
    [self showCommentsField];
    
    [self.viewRequestRide setHidden:YES];
    [self hideRequestingView:YES];
    [self hideCancelRequestingButton:YES];
    
    [self.viewSetPickupLocation setHidden:YES];
    [self updateDriverInfoAndUpdateTimers:YES];
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    
    CLLocation *pickupLocation = ride.startLocation.location;
    CLLocation *driverLocation = ride.activeDriver.location;
    CLLocationCoordinate2D driverCoord = driverLocation.coordinate;
    
    [self.googleMapsManager removePickupMarker];
    [self.googleMapsManager addPickupTimeMarkerWithView:self.pinViewWithTime toCoordinate:pickupLocation.coordinate];
    [self.googleMapsManager createOrUpdateDriverMarkerWithIconUrl:self.currentRide.requestedCarType.mapIconUrl coordinate:driverCoord course:driverLocation.course];
    
    if ([ride.endLocation.location isValid]) {
        [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:ride.endLocation.coordinate];
    }
    
    //RA-7335
    [self drawRouteFromDriver:driverLocation.coordinate toCoordinate:pickupLocation.coordinate];

    [self enableAutoMap]; //RA-7786. Ensure that if map is moved just before requesting, the map will zoom enough to show driver car.
    [self updateCameraZoomFromDriverLocation:driverCoord respectStartLocation:pickupLocation.coordinate];
    [self.btnETADestination setHidden:YES];
}

- (void)setViewToStateDriverReached {
    BFLog(@"set view Driver Reached");
    [self updateNavigationTitle:[@"Driver Arrived" localized]];
    
    RARideDataModel *ride = self.currentRide;
    self.btPickupAddress.text = [self.currentRideRequest startLocation].visibleAddress ?: ride.startLocation.visibleAddress;
    self.btDestinationAddress.text = [self.currentRideRequest endLocation].visibleAddress ?: ride.endLocation.visibleAddress;
    self.pickUpCommentTextField.text = ride.comment;

    [self showBothFields];
    [self showCommentsField];
    
    [self hideRequestingView:YES];
    [self hideCancelRequestingButton:YES];
    
    [self.viewRequestRide       setHidden:YES];
    [self.viewSetPickupLocation setHidden:YES];
    
    [self updateDriverInfoAndUpdateTimers:YES];
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    [self.googleMapsManager eraseRouteWithIdentifier:kActiveRouteIdentifier];
    
    CLLocation *pickupLocation = ride.startLocation.location;
    CLLocation *driverLocation = ride.activeDriver.location;
    CLLocationCoordinate2D driverCoord = driverLocation.coordinate;

    [self.googleMapsManager removePickupMarker];
    [self.googleMapsManager addPickupTimeMarkerWithView:self.pinViewWithTime toCoordinate:pickupLocation.coordinate];
    [self.googleMapsManager createOrUpdateDriverMarkerWithIconUrl:self.currentRide.requestedCarType.mapIconUrl coordinate:driverCoord course:driverLocation.course];

    if ([ride.endLocation.location isValid]) {
        [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:ride.endLocation.coordinate];
        [self drawRouteFromDriver:driverLocation.coordinate toCoordinate:ride.endLocation.location.coordinate];
        [self updateCameraZoomFromDriverLocation:driverCoord respectStartLocation:ride.endLocation.coordinate];
    } else {
        [self updateCameraZoomFromDriverLocation:driverCoord respectStartLocation:pickupLocation.coordinate];
    }
    
    [self.btnETADestination setHidden:YES];
}

- (void)setViewToStateTripStarted {
    BFLog(@"set view Trip Started");
    [self updateNavigationBarToTripStarted];
    RARideDataModel *ride = self.currentRide;
    
    self.btPickupAddress.text = [self.currentRideRequest startLocation].visibleAddress ?: ride.startLocation.visibleAddress;
    self.btDestinationAddress.text = [self.currentRideRequest endLocation].visibleAddress ?: ride.endLocation.visibleAddress;
    self.pickUpCommentTextField.text = ride.comment;

    [self showBothFields];
    [self hideCommentsField];
    
    [self hideRequestingView:YES];
    [self hideCancelRequestingButton:YES];
    
    [self.viewSetPickupLocation setHidden:YES];
    [self.viewRequestRide   setHidden:YES];
    [self.googleMapsManager removePickupTimeMarker];
    
    CLLocation *startLocation = ride.startLocation.location;
    RARideLocationDataModel *endLocation = ride.endLocation;
    
    [self.googleMapsManager createOrUpdatePickupMarkerWithCoordinate:startLocation.coordinate];
    if ([endLocation.location isValid]) {
        [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:endLocation.coordinate];
    }
    
    [self updateDriverInfoAndUpdateTimers:NO];
    [self updatePadding]; //must update padding after hiding/showing views and before animate camera to fit coordinates using insets.
    
    CLLocation *driverLocation = ride.activeDriver.location;
    CLLocationCoordinate2D  driverCoordinate = driverLocation.coordinate;
    
    [self.googleMapsManager createOrUpdateDriverMarkerWithIconUrl:ride.requestedCarType.mapIconUrl coordinate:driverCoordinate course:driverLocation.course];
    
    if ([endLocation.location isValid]) {
        [self drawRouteFromDriver:ride.activeDriver.location.coordinate toCoordinate:endLocation.location.coordinate];
    } else {
        [self.googleMapsManager animateCameraToCoordinate:driverCoordinate zoom:kDefaultMapZoom];
    }
    
    [self.btnETADestination setSelected:NO];
    if (self.currentRide.estimatedCompletionDate) {
        [self updateEstimatedCompletionTime];
    }
}

- (void)setViewToStateRideCleanup {
    BFLog(@"set view RideCleanup");
    [[RARideRequestManager sharedManager] deleteRideRequest];
    self.pickUpCommentTextField.text = nil;
    self.btDestinationAddress.text = @"";
    [self hideCommentsField];
    [self.googleMapView clear];
    [self.googleMapsManager removeTripMarkers];
    [self setViewToStateInitial];
}

- (void)updateNavigationBarWithState:(RALocationViewState)state {
    
    UIBarButtonItem *btn;
    switch (state) {
        case RALocationViewStateClear:
        case RALocationViewStatePrepared:
        case RALocationViewStateRequesting:
        case RALocationViewStateInitial:
        case RALocationViewStateRideAssigned:
        case RALocationViewStateTripCanceled:
        case RALocationViewStateRating:
            btn = self.btFindLocation;
            break;
        
        case RALocationViewStateWaitingDriver:
        case RALocationViewStateDriverReached:
        case RALocationViewStateTripStarted: {
            btn = self.btContact;
        }
            break;
    }
    if (self.navigationItem.rightBarButtonItem != btn) {
        self.navigationItem.rightBarButtonItem = btn;
    }
}

- (void)updateDriverInfoAndUpdateTimers:(BOOL)shouldUpdateTimers {
    [self.viewDriver updateBasedOnRide:self.currentRide];
    if (shouldUpdateTimers) {
        [self updateActiveDriverArrivalTime:self.currentRide.activeDriver.timeToReachRider];
        [self updateEstimatedCompletionTime];
    }
}

- (void)updateActiveDriverLocation:(CLLocation *)driverLocation {
    [self.googleMapsManager createOrUpdateDriverMarkerWithIconUrl:self.currentRide.requestedCarType.mapIconUrl coordinate:driverLocation.coordinate course:driverLocation.course];
    
    RARideDataModel *currentRide = self.currentRide;
    RARideStatus status = currentRide.status;
    if (status == RARideStatusDriverAssigned) {
        CLLocation *pickupLocation = currentRide.startLocation.location;
        [self updateCameraZoomFromDriverLocation:driverLocation.coordinate respectStartLocation:pickupLocation.coordinate];
        [self updateActiveDriverArrivalTime:self.currentRide.activeDriver.timeToReachRider];
        [self drawRouteFromDriver:driverLocation.coordinate toCoordinate:pickupLocation.coordinate];
    } else if (status == RARideStatusDriverReached){
        if ([currentRide.endLocation.location isValid]) {
            CLLocationCoordinate2D endCoord = currentRide.endLocation.coordinate;
            [self updateCameraZoomFromDriverLocation:driverLocation.coordinate respectStartLocation:endCoord];
            [self updateActiveDriverArrivalTime:self.currentRide.activeDriver.timeToReachRider];
            [self drawRouteFromDriver:driverLocation.coordinate toCoordinate:currentRide.endLocation.location.coordinate];
        } else {
            [self.googleMapsManager eraseRouteWithIdentifier:kActiveRouteIdentifier];
        }
    } else if (status == RARideStatusActive){
        [self updateEstimatedCompletionTime];
        if ([self.currentRide.endLocation.location isValid]) {
            [self drawRouteFromDriver:driverLocation.coordinate toCoordinate:currentRide.endLocation.location.coordinate];
        } else {
            if (self.isAutoMoveEnabled) {
                [self.googleMapsManager animateCameraToCoordinate:driverLocation.coordinate zoom:kDefaultMapZoom];
            }
        }

    }
}

- (void)updateActiveDriverArrivalTime:(NSNumber *)arrivalTime {
    if (![[RARideManager sharedManager] isDriverComing]) {
        self.pinViewWithTime_min.text = @"0";
        return;
    }
    
    if (!arrivalTime) {
        self.pinViewWithTime_min.text = @"- -";
        return;
    }
    
    long seconds = [arrivalTime longValue];
    long min = seconds/60;
    self.pinViewWithTime_min.text = (min == 0) ? @"< 1" : [NSString stringWithFormat:@"%ld ", min];
}

- (void)updateEstimatedCompletionTime {
    NSDate *estimatedCompletionDate = self.currentRide.estimatedCompletionDate;
    if (!estimatedCompletionDate || !self.currentRide.endLocation.location.isValid || self.shouldHideBtnETADestination) {
        [self.btnETADestination setHidden:YES];
        return;
    }
    
    if (self.btnETADestination.isSelected) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        
        NSString *etaTitle = [dateFormatter stringFromDate:estimatedCompletionDate];
        
        NSDictionary *baseAttributes = @{NSFontAttributeName : [UIFont fontWithName:FontTypeLight size:14.0]};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:[@"DESTINATION_ARRIVAL_ETA" localized], etaTitle] attributes:baseAttributes];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontTypeRegular size:14.0] range:[attributedString.string rangeOfString:etaTitle]];
        
        [self.btnETADestination setAttributedTitle:attributedString forState:UIControlStateNormal];
    } else {
        NSTimeInterval seconds = MAX(estimatedCompletionDate.timeIntervalSinceNow, 0);
        long minutes = seconds / 60;
        
        NSString *title = (minutes == 0) ? [@"DESTINATION_ARRIVAL_LESS_THAN_ONE_MINUTE" localized] : [NSString stringWithFormat:[@"DESTINATION_ARRIVAL_MINUTES" localized], minutes];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont fontWithName:FontTypeRegular size:14.0]}];
        [self.btnETADestination setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
    
    [self.btnETADestination setHidden:NO];
}

- (void)showOrHideStackedRideViewBasedOnPrecedingRide {
    if (self.currentRide.precedingRide && [[RARideManager sharedManager] isRiding:self.currentRide.precedingRide.status]) {
        [self.mainCoordinator showStackedRideInfoInViewController:self];
        [self updatePrecedingRideMarker];
    } else {
        [self.mainCoordinator hideStackedRideInfo];
        [self.googleMapsManager removePrecedingTripMarker];
    }
}

- (void)updatePrecedingRideMarker {
    CLLocationCoordinate2D precedingRideDestination = self.currentRide.precedingRide.endCoordinate;
    if ([CLLocation isCoordinateNonZero:precedingRideDestination]) {
        [self.googleMapsManager createOrUpdatePrecedingTripMarkerWithCoordinate:precedingRideDestination];
    } else {
        [self.googleMapsManager removePrecedingTripMarker];
    }
}

- (void)hideRequestingView:(BOOL)hide {
    [self.viewShimmeringRequesting setHidden:hide];
    
    if (hide) {
        [self.lblRequesting stopGlowing];
    } else {
        __weak LocationViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.lblRequesting startGlowingWithColor:[UIColor whiteColor] intensity:0.6];
        });
    }
    [self.lblRequesting setHidden:hide];
}

- (void)hideCancelRequestingButton:(BOOL)hide {
    if (hide) {
        [self.btnCloseRequesting stopGlowing];
    } else {
        [self.btnCloseRequesting startGlowing];
    }
    [self.btnCloseRequesting setHidden:hide];
}

- (void)hideAddressFields {
    [self.viewPickupField setHidden:YES];
    [self.viewDestinationField setHidden:YES];
}

- (void)showBothFields {
    [self.viewPickupField setHidden:NO];
    [self.viewDestinationField setHidden:NO];
}

- (void)showCommentsField {
    [self.pickUpCommentTextField setHidden:NO];
    [self.pickUpCommentTextField setReturnKeyType:[[RARideManager sharedManager] isRiding] ? UIReturnKeySend : UIReturnKeyDone];
    self.commentHeightConstraint.constant = 50;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.pickUpCommentTextField setEnabled:YES];
    }];
}

- (void)hideCommentsField {
    self.commentHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.pickUpCommentTextField setEnabled:NO];
        [self.pickUpCommentTextField setHidden:YES];
    }];
}

- (void)makeSelectionRestricted {
    [self.viewSetPickupLocation showNotAvailableWithTitle:nil];
}

- (void)makeSelectionRestrictedAndShowNotAvailableLabel {
    [self.viewSetPickupLocation showNotAvailableWithTitle:@"Coming soon in your area"];
}

- (void)hideNotAvailabelLabelAndMakeSelectionAllowed {
    [self.viewSetPickupLocation showAvailable];
}

- (void)toggleViewCategoryMainView {
    BOOL isVisible = self.bottomConstraintFareView.constant == self.viewCategoryMainView.constantWithVisibleDrawer;
    if (isVisible) {
        [self collapseViewCategoryMainView];
    } else {
        [self expandViewCategoryMainView];
    }
}

- (IBAction)btnEtaDestinationTapped:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self updateEstimatedCompletionTime];
}

- (void)expandViewCategoryMainView {
    [self.viewCategoryMainView updateLabelsWithPickupETA:self.currentActiveDriverETA];
    self.bottomConstraintFareView.constant = self.viewCategoryMainView.constantWithVisibleDrawer;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.viewCategoryMainView.ivChevron.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)collapseViewCategoryMainView {
    self.bottomConstraintFareView.constant = self.viewCategoryMainView.constantWithVisibleSlider;
    [UIView animateWithDuration:0.5 animations:^{
        self.viewCategoryMainView.ivChevron.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        [self.view layoutIfNeeded];
    }];
}

@end

#pragma mark - Events

@implementation LocationViewController (Events)

- (void)observeEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventsPollingHasReceivedNewEventNotification:)
                                                 name:kEventsLongPollingHasReceivedNewEventNotification
                                               object:nil];
}

- (void)unobserveEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kEventsLongPollingHasReceivedNewEventNotification
                                                  object:nil];
}

- (void)eventsPollingHasReceivedNewEventNotification:(NSNotification *)notification {
    RAEventDataModel *event = (RAEventDataModel*)notification.object;
    DBLog(@"new event received: %@",event);
    switch (event.type) {
        case RAEventSurgeAreaUpdate:
            [self handleSurgeAreaUpdateEvent:event];
            break;
            
        case RAEventSurgeAreaUpdates:
            [self handleSurgeAreaUpdatesEvent:event];
            break;
            
        default:
            break;
    }
}

- (void)handleSurgeAreaUpdateEvent:(id<RASurgeAreaEventProtocol>)event {
    RASurgeAreaDataModel *surgeArea = event.updatedSurgeArea;
    if ([surgeArea boundaryContainsLocation:self.currentLocation.location]) {
        [self processSurgeAreas:@[surgeArea] withCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSurgeAreaUpdateNotification object:nil];
        }];
    }
}

- (void)handleSurgeAreaUpdatesEvent:(id<RASurgeAreasEventProtocol>)event {
    __weak LocationViewController *weakSelf = self;
    NSArray *surgeAreasInCurrentLocation = [event.updatedSurgeAreas filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RASurgeAreaDataModel *_Nullable surgeArea, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [surgeArea boundaryContainsLocation:weakSelf.currentLocation.location];
    }]];
    
    if (surgeAreasInCurrentLocation && surgeAreasInCurrentLocation.count > 0) {
        [self processSurgeAreas:surgeAreasInCurrentLocation withCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSurgeAreaUpdateNotification object:nil];
        }];
    }
}

@end

#pragma mark - Active Drivers

@implementation LocationViewController (ActiveDrivers)

- (RAActiveDriversRequest*)activeDriverRequest {
    RAActiveDriversRequest *acdrRequest = [RAActiveDriversRequest new];
    acdrRequest.location = self.currentRideRequest ? self.currentRideRequest.startLocation.coordinate : self.currentLocation.coordinate;
    acdrRequest.carCategory = self.selectedCategory;
    acdrRequest.womanOnlyMode = [[RARideRequestManager sharedManager] isWomanOnlyModeOn];
    acdrRequest.isFingerPrintedDriverOnlyMode = [[RARideRequestManager sharedManager] isFingerprintedDriverOnlyModeOn];
    return acdrRequest;
}

- (void)startPollingForActiveDrivers {
    if (![[RARideManager sharedManager] isRiding]) {
        if ([[RAActiveDriversManager sharedManager] isPolling]) {
            [[RAActiveDriversManager sharedManager] updateRequest:[self activeDriverRequest]];
        } else {
            __weak LocationViewController *weakSelf = self;
            [[RAActiveDriversManager sharedManager] startPollingWithRequest:[self activeDriverRequest] andCompletion:^(NSArray<RAActiveDriverDataModel *> *activeDrivers, NSURL *categoryMapIconURL, NSError *error) {
                if (!error) {
                    weakSelf.currentActiveDriverETA = [weakSelf getETAFromActiveDrivers:activeDrivers];
                    if ([[RARideManager sharedManager] isRiding]) { //Ensure that ride was not synchronizing while requested active drivers and it was in a ride.
                        [weakSelf.googleMapsManager removeAllNearbyDrivers];
                    } else {
                        [weakSelf.googleMapsManager showNearbyDrivers:activeDrivers withCarIconUrl:categoryMapIconURL];
                    }
                    
                    if (weakSelf.googleMapsManager.currentNearbyCarsIdentifier.count == 0 || weakSelf.currentActiveDriverETA == NSNotFound) {
                        [weakSelf.viewRequestRide.lbPickupTimeMessage setHidden:YES];
                        [weakSelf.viewSetPickupLocation cleanLayers];
                    } else {
                        [weakSelf.viewRequestRide.lbPickupTimeMessage setHidden:NO];
                        weakSelf.viewRequestRide.lbPickupTimeMessage.text = [NSString stringWithFormat:[@"Pickup time is approximately %ld mins" localized], weakSelf.currentActiveDriverETA/60];
                        [weakSelf.viewSetPickupLocation showLoaded];
                    }
                    
                    [weakSelf.viewSetPickupLocation updateETA:weakSelf.currentActiveDriverETA];
                    [weakSelf.viewCategoryMainView updateLabelsWithPickupETA:weakSelf.currentActiveDriverETA];
                    
                } else {
                    DBLog(@"error getting active drivers: %@",error);
                    [weakSelf stopPollingForActiveDrivers];
                }
            }];
        }
    }
}

- (void)stopPollingForActiveDrivers {
    [[RAActiveDriversManager sharedManager] stopPolling];
    self.currentActiveDriverETA = NSNotFound;
    [self.googleMapsManager removeAllNearbyDrivers];
}

- (NSInteger)getETAFromActiveDrivers:(NSArray<RAActiveDriverDataModel *> *)activeDrivers {
    NSInteger eta = NSNotFound;
    
    for (RAActiveDriverDataModel *acdr in activeDrivers) {
        NSInteger time = [acdr.timeToReachRider integerValue];
        eta = (time < eta) ? time : eta;
    }
    
    return eta;
}

@end

#pragma mark - GoogleMaps

@implementation LocationViewController (GoogleMaps)

- (void)configureMapWithCurrrentLocation {
    CLLocation *myLocation = [LocationService sharedService].myLocation;
    [self configureMapWithLocation:myLocation];
}

- (void)configureMapWithLocation:(CLLocation*)location {
    if (location && [location isValid]) {
        [self setUpMapWithLocation:location];
    } else {
        [self getMyCurrentLocationWithCompletion:^(CLLocation *location, NSError *error) {
            if (!error) {
                [self setUpMapWithLocation:location];
            } else {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
                [self setUpMapWithLocation:location];
            }
        }];
    }
}

- (void)setUpMapWithLocation:(CLLocation*)location {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:kDefaultMapZoom];
    [self.googleMapView setCamera:camera];
    self.googleMapView.delegate = self;
    self.googleMapView.indoorEnabled = NO;
    self.googleMapView.mapType = kGMSTypeNormal;
    self.googleMapView.accessibilityElementsHidden = YES;
    self.googleMapView.settings.rotateGestures = NO;
    self.googleMapView.settings.allowScrollGesturesDuringRotateOrZoom = NO;
    self.googleMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:
     @[
       [self.googleMapView.topAnchor constraintEqualToAnchor:self.view.compatibleTopAnchor],
       [self.googleMapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
       [self.googleMapView.leadingAnchor constraintEqualToAnchor:self.view.compatibleLeadingAnchor],
       [self.googleMapView.trailingAnchor constraintEqualToAnchor:self.view.compatibleTrailingAnchor]
       ]];
#ifdef AUTOMATION
    self.googleMapView.accessibilityElementsHidden = NO;
#endif
    
    self.googleMapsManager = [[GoogleMapsManager alloc] initWithMap:self.googleMapView];
    [self.googleMapsManager showMyLocation:YES];
    
    [self updatePadding];
    [self geoReverseCoordinate:location.coordinate];
}

- (void)getMyCurrentLocationWithCompletion:(LocationResult)completion {
    if (self.googleMapsManager) {
        CLLocation *locationFromMap = [self.googleMapsManager getMyCurrentLocation];
        if (locationFromMap) {
            completion(locationFromMap,nil);
            return;
        }
    }
    
    [[LocationService sharedService] getMyCurrentLocationWithCompleteBlock:^(CLLocation *location, NSError *error) {
        if (!error) {
            completion(location,nil);
        } else {
            [LocationService getLocationBasedOnIPAddressWithCompletion:^(CLLocation *location, NSError *error) {
                completion(location,error);
            }];
        }
    }];
}

- (void)updatePadding {

    CGFloat paddingBottomOffset = kGoogleMapInitialBottomPadding;
    
    BOOL onTrip = self.viewDriver.hidden == NO;
    if (onTrip) {
        paddingBottomOffset = 35;
    }
    
    [self.googleMapsManager setPadding: UIEdgeInsetsMake(0.0, 0.0, paddingBottomOffset, 0.0)];
    
}

- (void)drawRouteFromDriver:(CLLocationCoordinate2D)driverCoordinate toCoordinate:(CLLocationCoordinate2D)endCoordinate {
    __weak LocationViewController *weakSelf = self;
    
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];
    CLLocation *precedingRideWaypoint = self.currentRide.precedingRide.endLocation.location;
    if (precedingRideWaypoint) {
        [waypoints addObject:precedingRideWaypoint];
    }
    
    [self.googleMapsManager getRouteFrom:driverCoordinate to:endCoordinate waypoints:waypoints completion:^(GMSPolyline * _Nullable polyline, GMSCoordinateBounds * _Nullable bounds, NSError * _Nullable error) {
        //RA-7335: check for driver coming, RA-8556: check for driver arrived
        if ([[RARideManager sharedManager] isOnTrip] || [[RARideManager sharedManager] isDriverComing] || [[RARideManager sharedManager] isDriverArrived]){ //The completion block can return after completing ride and view changed so it can draw route in a wrong state
            if (error) {
                if ([error.domain isEqualToString:kInvalidRouteCoordinateErrorDomain]) {
                    [weakSelf.googleMapsManager eraseRouteWithIdentifier:kActiveRouteIdentifier];
                } else {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                }
            } else {
                polyline.strokeWidth = 8;
                polyline.strokeColor = [UIColor routeBlue];
                
                [weakSelf.googleMapsManager drawRoute:polyline withIdentifier:kActiveRouteIdentifier];
                [self updateCameraZoomFromDriverLocation:driverCoordinate respectStartLocation:endCoordinate];
            }
        }
    }];
}

- (void)updateCameraZoomFromDriverLocation:(CLLocationCoordinate2D)driverCoord respectStartLocation:(CLLocationCoordinate2D)startCoord {
    // Calcualate if driver reach near the rider zoom accordingly
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:startCoord.latitude longitude:startCoord.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:driverCoord.latitude longitude:driverCoord.longitude];
    CLLocationDistance meters = [locB distanceFromLocation:locA];
    
    if (!self.isAutoMoveEnabled) {
        return;
    }
    
    if (meters >= kLocationViewControllerMaxDistanceZoomBetweenCoords) {
        [self.googleMapsManager animateCameraToFitBounds:[self.googleMapsManager boundsForRouteWithIdentifier:kActiveRouteIdentifier] withEdgeInsets:self.insetsForMap];
    } else {
        [self.googleMapsManager animateCameraToFitStartCoordinate:startCoord endCoordinate:driverCoord withEdgeInsets:self.insetsForMap];
        [self.googleMapsManager animateToZoom:kDefaultMapZoom];
    }
}

- (void)showPins {
    CLLocation *startLocation = self.currentRideRequest.startLocation.location;
    CLLocation *endLocation = self.currentRideRequest.endLocation.location;
    
    if ([startLocation isValid] && [endLocation isValid]) {
        [self.googleMapsManager animateCameraToFitStartCoordinate:startLocation.coordinate
                                                    endCoordinate:endLocation.coordinate
                                                   withEdgeInsets:self.insetsForMap];
    }
}

#pragma mark GoogleMaps Delegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self dismissKeyboard];
    [self collapseViewCategoryMainView];
    [self.viewDriver collapse];
    if (!self.preselectedComment && !self.preselectedDestination && !self.currentRideRequest) {
        [self hideCommentsField];
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self.viewSetPickupLocation disableSetPickUpButton];
    [self.viewSetPickupLocation hidePickupButtonShowPin];
    
    if (gesture) {
        [self dismissKeyboard];
        
        if (![[RARideManager sharedManager] isRiding] && !self.currentRideRequest) {
            self.isLocationSelectedFromValidSource = NO;
        }
        
        [self disableAutoMoveAndZoom];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    
#ifdef AUTOMATION
    self.googleMapView.accessibilityValue = [NSString stringWithFormat:@"ZOOM:%f;LAT:%f;LNG:%f",position.zoom,position.target.latitude,position.target.longitude];
#endif
    
    [self.viewSetPickupLocation showPickupButtonHidePin];
    BOOL differentPlace = ![RARideManager rideCoordinate:position.target isEqualToOtherRideCoordinate:self.currentLocation.coordinate];
    if(differentPlace && ![self isLocationSelectedFromValidSource] && !([[RARideManager sharedManager] isRiding] || self.currentRideRequest)) {
        [self.viewSetPickupLocation showLoadingAnimation];
        [self geoReverseCoordinate:position.target];
    } else {
        if ([ConfigurationManager currentCityContainsCoordinate:position.target]) {
            [self.viewSetPickupLocation enableSetPickUpButton];
        }
    }
}

- (void)geoReverseCoordinate:(CLLocationCoordinate2D)coordinate {
    __weak LocationViewController *weakSelf = self;
    [[GeocoderService sharedInstance] reverseGeocodeForCoordinate:coordinate completion:^(RAAddress * _Nullable address, NSError * _Nullable error) {
        //RA-8703 (along with fixes in RA-8688). Prevent concurrency to change pick up address when in a ride.
        if ([[RARideManager sharedManager] isRiding]) {
            return;
        }
        
        //RA-9673. Avoid changing anything if it is setting source.
        if ([weakSelf isSettingSource]) {
            return;
        }
        
        if (!error) {
            
            [weakSelf updateCurrentLocation:coordinate withAddress:address];
            
            if (weakSelf.btPickupAddress.isFirstResponder == NO) {
                weakSelf.btPickupAddress.text = weakSelf.currentLocation.visibleAddress;
            }
            
            [weakSelf startPollingForActiveDrivers];
            
            //Refresh Category Slider
            [weakSelf reloadCategories];
            
            if (![ConfigurationManager currentCityContainsCoordinate:coordinate]) {
                [weakSelf.viewCategoryMainView.categorySlider clearAllSurgeAreas];
                [weakSelf makeSelectionRestrictedAndShowNotAvailableLabel];
            } else {
                [weakSelf hideNotAvailabelLabelAndMakeSelectionAllowed];
                
                if (![[RARideManager sharedManager] isOnTrip]) {
                    [weakSelf checkSurgeAvailabilityForLocation:coordinate withCompletion:^(NSError *error) {
                        if(error){
                            [RAAlertManager showErrorWithAlertItem:error
                                                        andOptions:[RAAlertOption optionWithState:StateActive]];
                        }
                    }];
                }
            }
            
        } else {
            [RAAlertManager showErrorWithAlertItem:[@"Sorry we could not determine your location." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
            [weakSelf.viewCategoryMainView.categorySlider clearAllSurgeAreas];
            [weakSelf makeSelectionRestricted];
        }
    }];
}

@end

#pragma mark - Accessibility

@implementation LocationViewController (Accessibility)

- (void)configureAccessibility {
    //Requesting
    self.btnCloseRequesting.accessibilityLabel = [@"Cancel your request" localized];
    self.btnCloseRequesting.accessibilityHint  = [@"You are requesting a ride, please wait while we look for a driver or tap to cancel request" localized];
}

@end

#pragma mark - Woman only Delegate

@implementation LocationViewController (WomanOnlyDelegate)

- (void)womanOnlyModeChanged {
    [self reloadCategories];
    if (![[RARideManager sharedManager] isRiding]) {
        [self mapView:self.googleMapView idleAtCameraPosition:self.googleMapView.camera];
        
        //RA-12358 recreate active drivers poll
        [self stopPollingForActiveDrivers];
        [self startPollingForActiveDrivers];
    }
    
    if (self.viewRequestRide.hidden == NO) {
        [self requestRideView:self.viewRequestRide didTapCancel:nil];
    }
}

@end

#pragma mark - Car Categories

@implementation LocationViewController (CarCategories)

- (void)loadCategorySlider {
    self.categories = [CarCategoriesManager getCategoriesValidForLocation:self.currentLocation.location];
    if (self.categories.count > 0 && !self.viewCategoryMainView.categorySlider.dataSource) {
        [self.viewCategoryMainView.categorySlider setDataSource:self];
        [self collapseViewCategoryMainView];
    }
}

- (void)reloadCategories {
    NSArray<RACarCategoryDataModel*> *categoriesRestricted = [CarCategoriesManager getCategoriesValidForLocation:self.currentLocation.location];
    
    BOOL needToReload = [categoriesRestricted count] != [self.categories count];
    
    if (!needToReload) {
        for (RACarCategoryDataModel *category in categoriesRestricted) {
            if (![self.categories containsObject:category]) {
                needToReload = YES;
                break;
            }
        }
    }
    
    if (!needToReload) {
        if (![[self.categories valueForKey:@"sliderIconUrl"] isEqualToArray:[categoriesRestricted valueForKey:@"sliderIconUrl"]]) {
            needToReload = YES;
        }
    }
    
    if (needToReload) {
        self.categories = categoriesRestricted;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewCategoryMainView.categorySlider reloadData];
        });
    }
}

#pragma mark Car Categories Datasource

- (NSUInteger)numberOfNodesInCategorySlider {
    return self.categories.count;
}

- (RACarCategoryDataModel*)categoryAtIndex:(int)index {
    return [self.categories objectAtIndex:index];
}

- (NSUInteger)indexForCategory:(RACarCategoryDataModel *)category {
    if (self.categories) {
        return [self.categories indexOfObject:category];
    } else {
        return NSNotFound;
    }
}

- (void)didTapCategoryHandler {
    [self toggleViewCategoryMainView];
}

@end

#pragma mark Split Fare
@implementation LocationViewController (SplitFare)

#pragma mark SplitFare Push Delegate

- (void)splitFarePushAcceptedFromContact:(Contact *)targetContact {
    [self reloadSplitFareResponseWithContact:targetContact pushType:SFPushTypeAccepted];
}

- (void)splitFarePushRejectedFromContact:(Contact *)targetContact {
    [self reloadSplitFareResponseWithContact:targetContact pushType:SFPushTypeDeclined];
}

- (void)reloadSplitFareResponseWithContact:(Contact *)targetContact pushType:(SFPushType)pushType {
    if (self.isSplitFareAlertDisplaying) {
        return;
    }
    
    self.isSplitFareAlertDisplaying = YES;
    
    __weak LocationViewController *weakSelf = self;
    SplitFareInvitationAlert *alert = [SplitFareInvitationAlert splitPopupWithContact:targetContact pushType:pushType completion:^(NSString *splitFareId, BOOL isAccepted) {
        weakSelf.isSplitFareAlertDisplaying = NO;
    }];
    [alert show];
    
    [[SplitFareManager sharedManager] reloadDataWithRideId:self.currentRide.modelID.stringValue andCompletion:^(NSError *error, BOOL stopPolling) {
        if (stopPolling) {
            [[SplitFareManager sharedManager] stopPolling];
        }
    }];
}

- (void)splitFarePushRequestedWithId:(NSString *)splitId rideId:(NSString *)rideId fromContact:(Contact *)sender {

    if (self.isSplitFareAlertDisplaying) {
        if (self.splitFareRequestedAlert && [self.splitFareRequestedAlert.rideId isEqualToString:rideId]) {
            self.splitFareRequestedAlert.splitFareId = splitId;
        }
        return;
    }
    
    self.isSplitFareAlertDisplaying = YES;
    
    __weak LocationViewController *weakSelf = self;
    self.splitFareRequestedAlert = [SplitFareInvitationAlert splitPopupWithContact:sender pushType:SFPushTypeRequested completion:^(NSString *splitFareId, BOOL isAccepted) {
        weakSelf.splitFareRequestedAlert = nil;
        weakSelf.isSplitFareAlertDisplaying = NO;
        SplitResponse *response = [[SplitResponse alloc] initWithSplitID:splitFareId andResponse:isAccepted];
        [[SplitFareManager sharedManager] respondToSplitRequestWithSPlitResponse:response];
    }];

    self.splitFareRequestedAlert.rideId = rideId;
    self.splitFareRequestedAlert.splitFareId = splitId;
    [self.splitFareRequestedAlert show];
}

@end

#pragma mark - Idle Map Timer

@implementation LocationViewController (IdleMapTimer)

- (void)disableAutoMoveAndZoom {
    //check if not valid ride to disable auto move/zoom
    if (![[RARideManager sharedManager] isRiding]) {
        return;
    }
    
    self.isAutoMoveEnabled = NO;
    
    const CGFloat kMapIdleTimeInterval = 7;
    [self performSelector:@selector(enableAutoMap) withObject:nil afterDelay:kMapIdleTimeInterval];
}

- (void)enableAutoMap {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableAutoMap) object:nil];
    self.isAutoMoveEnabled = YES;
}

@end


#pragma mark - Rating

@implementation LocationViewController (Rating)

- (void)loadCurrentUnratedRide {
    [UnratedRideManager checkForRatedRides];
    if (![[RARideManager sharedManager] isRiding]) {
        self.currentUnratedRide = [UnratedRideManager checkRideToRate];
    }
}

- (void)addUnratedRide:(RARideDataModel *)ride {
    if (ride) {
        [UnratedRideManager addUnratedRide:ride.modelID.stringValue];
        self.currentUnratedRide = ride.modelID.stringValue;
    }
}

- (void)showRatingViewForRide:(NSString *)rideID {
    if (self.navigationController.presentedViewController != nil) {
        BFLog(@"%@ was open, while trying to show RatingViewController", NSStringFromClass([self.navigationController.presentedViewController class]));
        return;
    }
    
    __weak LocationViewController *weakSelf = self;
    [RARideAPI getRide:rideID withRiderLocation:nil andCompletion:^(RARideDataModel *ride, NSError *error) {
        if (ride && !ride.rating) {
            UnratedRide *unrated = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:[RASessionManager sharedManager].currentRider.preferredPaymentMethod];
            RatingViewController *rateVC = [RatingViewController new];
            rateVC.viewModel = [[RatingViewModel alloc] initWithRide:unrated configuration:[ConfigurationManager shared]];
            rateVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            dispatch_async(dispatch_get_main_queue(), ^{
                BFLog(@"Showing rating screen for ride with id: %@", ride.modelID);
                [weakSelf.navigationController presentViewController:rateVC animated:YES completion:nil];
            });
        } else {
            if (!ride || ride.rating) {
                BFLogWarn(@"Rating screen not shown - Ride %@ <null or already rated>", ride);
            } else if (error) {
                BFLogErr(@"Error to get ride to show rating screen %@", error);
            }
        }
     }];
}

@end

#pragma mark - Round Up

@implementation LocationViewController (RoundUp)

- (void)showRoundUpAlertIfNeeded {
    if ([self shouldShowRoundUpAlert]) {
        [self showRoundUpAlert];
    }
}

- (BOOL)shouldShowRoundUpAlert {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    return rider.charity == nil && ![PersistenceManager isCancelRoundUpPopupReachedLimit];
}

- (void)showRoundUpAlert {
    self.popupRoundUpAlert = [KLCPopup popupWithContentView:self.viewRoundUpAlert
                                               showType:KLCPopupShowTypeBounceIn
                                            dismissType:KLCPopupDismissTypeBounceOut
                                               maskType:KLCPopupMaskTypeDimmed
                               dismissOnBackgroundTouch:NO
                                  dismissOnContentTouch:NO];
    
    [self.popupRoundUpAlert show];
}

@end

#pragma mark - Place Search

@implementation LocationViewController (PickerAddressDelegate)

- (void)pickerAddressViewController:(PickerAddressViewController *)pickerAddressViewController didSelectPlace:(RAPlace *)place {
    RAPickerAddressFieldType pickerAddressFieldType = [pickerAddressViewController pickerAddressFieldType];
    if (pickerAddressFieldType == RAPickerAddressPickupFieldType) {
        __weak __typeof__(self) weakself = self;
        self.isLocationSelectedFromValidSource = YES;
        [self validateStartAddressWithCoordinate:place.coordinate address:place.shortAddress andVisibleAddress:place.visibleAddress zipCode:place.zipCode  withCompletion:^(BOOL didSelectPlace) {
            if (didSelectPlace) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }
        }];
    } else if (pickerAddressFieldType == RAPickerAddressDestinationFieldType) {
        [self selectDestination:place.coordinate address:place.shortAddress visibleAddress:place.visibleAddress zipCode:place.zipCode];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSAssert(NO, @"Unknown RAPickerAddressFieldType");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didRemoveDestinationFromPickerAddressViewController:(PickerAddressViewController *)pickerAddressViewController {
    self.btDestinationAddress.text = @"";
    self.preselectedDestination = nil;
    [[RARideRequestManager sharedManager] riderHasSelectedDestinationLocation:nil];
    [self.googleMapsManager removeDestinationMarker];
    [self.googleMapsManager animateCameraToCoordinate:self.preselectedSource.coordinate];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

#pragma mark - Textfield Delegate

@implementation LocationViewController (UITextFieldDelegate)

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.pickUpCommentTextField) {
        self.preselectedComment = nil;
        [[RARideRequestManager sharedManager] riderHasWrittenPickUpComment:nil];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.pickUpCommentTextField) {
        NSString *commentWithWhiteSpaceTrimmed = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        commentWithWhiteSpaceTrimmed = commentWithWhiteSpaceTrimmed > 0 ? commentWithWhiteSpaceTrimmed : nil;
        
        self.pickUpCommentTextField.text = commentWithWhiteSpaceTrimmed;
        self.preselectedComment = commentWithWhiteSpaceTrimmed;
        [[RARideRequestManager sharedManager] riderHasWrittenPickUpComment:commentWithWhiteSpaceTrimmed];
        
        if (commentWithWhiteSpaceTrimmed.length == 0) {
            return;
        }
        
        if ([RARideManager sharedManager].isRiding) {
            [self showHUD];
            __weak LocationViewController *weakSelf = self;
            [[RARideManager sharedManager] updateComment:textField.text completion:^(NSError *error) {
                [weakSelf hideHUD];
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:nil];
                }
            }];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.pickUpCommentTextField) {
        BOOL reachedLimit = newString.length > 200;
        if (reachedLimit) {
            [RAAlertManager showAlertWithTitle:[@"Pick up comment" localized] message:[@"Maximum length is 200 characters." localized]];
        }
        return !reachedLimit;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.pickUpCommentTextField) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

@end

#pragma mark - Reachability

@implementation LocationViewController (Reachability)

- (void)addReachabilityObserver {
    if (![RANetworkManager sharedManager].isNetworkReachable) {
        self.reachabilityChangedBlock(RANetworkNotReachable);
    }
    [[RANetworkManager sharedManager] addReachabilityObserver:self
                                           statusChangedBlock:self.reachabilityChangedBlock];
}

- (void(^)(RANetworkReachability networkReachability))reachabilityChangedBlock {
    __weak LocationViewController *weakSelf = self;
    return ^(RANetworkReachability networkReachability) {
        if (networkReachability != RANetworkReachable) {
            [weakSelf.tripCancellationAlert dismiss];
            [weakSelf showOfflineMessageViewWithMessage:[@"No internet connection." localized]];
        } else {
            [weakSelf mapView:weakSelf.googleMapView idleAtCameraPosition:weakSelf.googleMapView.camera];
            
            [[SplitFareManager sharedManager] checkCachedSplitResponseAndUpdate];
            
            //RA-3346
            if (weakSelf.needsToResendDestinationChanged && [[RARideManager sharedManager] isRiding]) {
                [weakSelf changeDestination];
            }
            
            [ConfigurationManager needsReload];
            
            [weakSelf showHUD];
            [weakSelf synchronizeRideWithCompletion:^{
                [weakSelf hideHUD];
            }];
            
            [weakSelf closeOfflineMessageView:nil];
            [weakSelf loadCurrentUnratedRide];
        }
    };
}

- (void)showOfflineMessageViewWithMessage:(NSString *)message {
    if (!self.offlineNotification) {
        self.offlineNotification = [RANotificationSlide notificationWithMessage:message andParentView:self.view];
        self.offlineNotification.delegate = self;
        
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            [self.offlineNotification show];
            [self.view layoutIfNeeded];
        } completion:nil];
        
    }
}

- (void)closeOfflineMessageView:(id)sender {
    if (self.offlineNotification) {
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            [self.offlineNotification close];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.offlineNotification = nil;
        }];
    }
}

- (void)didTapCloseNotificationSlide {
    [self closeOfflineMessageView:nil];
}

@end

#pragma mark - Notifications

@implementation LocationViewController (Notifications)

- (void)configureObservers {
    __weak LocationViewController *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidChangeConfiguration object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf reloadCategories];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidUpdateCurrentRider object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf updatePaymentDeficiencyView];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidChangeCurrentCityType object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakSelf.isStartLocationSelected) {
            [weakSelf updateNavigationBarToDefault];
        }
        
        if (!weakSelf.isStartLocationSelected && [RARideManager sharedManager].isRiding == NO) {
            [weakSelf mapView:weakSelf.googleMapView idleAtCameraPosition:weakSelf.googleMapView.camera];
        }
    }];
    
    //Reload visible address of Pickup/Destination fields when favorite (Home/Work) places changed
    [[NSNotificationCenter defaultCenter] addObserverForName:kFavoritePlaceChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        if (weakSelf.preselectedSource) {
            CLLocationCoordinate2D coordinate = weakSelf.preselectedSource.coordinate;
            NSString *address = weakSelf.preselectedSource.address;
            NSString *visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:coordinate] ?: address;
            BOOL isCoordinateAvailable = [ConfigurationManager currentCityContainsCoordinate:coordinate];
            NSString *zipCode = weakSelf.preselectedSource.zipCode;
            [weakSelf selectSource:coordinate address:address visibleAddress:visibleAddress isAvailable:isCoordinateAvailable zipCode:zipCode];
        }
        
        if (weakSelf.preselectedDestination) {
            CLLocationCoordinate2D coordinate = weakSelf.preselectedDestination.coordinate;
            NSString *address = weakSelf.preselectedDestination.address;
            NSString *visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:coordinate] ?: address;
            NSString *zipCode = weakSelf.preselectedDestination.zipCode;
            [weakSelf selectDestination:coordinate address:address visibleAddress:visibleAddress zipCode:zipCode];
        }
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLocationAuthorizationStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf configureMapWithCurrrentLocation];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDestinationFromSpotlightIfNeeded)
                                                 name:kPlaceSearchSelectedNotification
                                               object:nil];
    
    [[RARideManager sharedManager] addObserver:[self KVOController] withHandler:^(FBKVOController *observer, NSDictionary<NSString *,id> *change) {
        [weakSelf performChangesOnRide:change];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationShouldSynchronizeCurrentRide object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf showHUD];
        [weakSelf synchronizeRideWithCompletion:^{
            [weakSelf hideHUD];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPickerAddressWillAppear object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        weakSelf.shouldHideBtnETADestination = YES;
        [weakSelf updateEstimatedCompletionTime];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPickerAddressDidDisappear object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        weakSelf.shouldHideBtnETADestination = NO;
        [weakSelf updateEstimatedCompletionTime];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationAddressValuesFilled object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        BOOL requestIsFilled = [note.object boolValue];
        if (requestIsFilled) {
            [RARideAPI getRideEstimateFromStartLocation:weakSelf.currentRideRequest.startLocation.coordinate
                                          toEndLocation:weakSelf.currentRideRequest.endLocation.coordinate
                                             inCategory:weakSelf.selectedCategory
                                         withCompletion:^(RAEstimate *estimate, NSError *error) {
                                             if (error) {
                                                 [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                                                 [weakSelf.mainCoordinator hideCampaignMessage];
                                             } else {
                                                 if (estimate.campaignInfo) {
                                                     [weakSelf.mainCoordinator showCampaignMessage:estimate.campaignInfo inViewController:weakSelf];
                                                 } else {
                                                     [weakSelf.mainCoordinator hideCampaignMessage];
                                                 }
                                             }
                                         }];
        } else {
            [weakSelf.mainCoordinator hideCampaignMessage];
        }
    }];
    [self observeEvents];
}

- (void)applicationWillEnterForeground:(NSNotification*)notification {
    self.shouldRefreshMap = NO;
    
    dispatch_async(getMainQueue(), ^{
        [self.viewSetPickupLocation showLoadingAnimation];
    });
    
    [self configureRideManager];
    self.retryingSynchronize = NO;
    __weak LocationViewController *weakSelf;
    [self synchronizeRideWithCompletion:^{
        weakSelf.shouldRefreshMap = YES;
    }];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [[RARideManager sharedManager] setPollingConsumerDelegate:nil];
    [[SplitFareManager sharedManager] stopPolling];
    self.retryingSynchronize = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end

#pragma mark - Alerts

@implementation LocationViewController (Alerts)

- (void)showConfirmationAlertWithHandler:(ConfirmationAlertBlock)handler {
    UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"" message:[@"You have chosen to be picked up from a location that is not near your current GPS location. Are you sure you chose the correct pickup location?" localized] preferredStyle:UIAlertControllerStyleAlert];
    
    [confirmationAlert addAction:[UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(NO);
        }
    }]];
    
    [confirmationAlert addAction:[UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(YES);
        }
    }]];
    
    [self presentViewController:confirmationAlert animated:YES completion:nil];
}

@end

#pragma mark - Estimate Fare Delegate

@implementation LocationViewController (EstimatedFareViewDelegate)

- (void)estimatedViewChangedDestinationPressed {
    [self didTapAddressButton:self.btDestinationAddress];
}

@end

#pragma mark - Priority Fare

@implementation LocationViewController (PriorityFare)

/**
 * When we receive a new event of surge area updated it is sent in a queue with QOS Utiliy, so any UI update should be sent to the main queue to see it immediately.
 */
- (void)processSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas withCompletion:(SurgeAreaCompletion)completion {
    dispatch_async(getMainQueue(), ^{
        if (surgeAreas.count > 0) {
            [self.viewCategoryMainView.categorySlider reloadSurgeAreas:surgeAreas];
        } else {
            [self.viewCategoryMainView.categorySlider clearAllSurgeAreas];
        }
        
        [self reloadCategories];
        if (completion) {
            completion();
        }
    });
}

@end

#pragma mark - Helpers

@implementation LocationViewController (Helpers)

- (void)validateStartAddressWithCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString*)address andVisibleAddress:(NSString*)visibleAddress zipCode:(NSString *)zipCode withCompletion:(void (^)(BOOL))completion {
    __weak __typeof__(self) weakself = self;
    
    self.settingSource = YES;
    if ([ConfigurationManager currentCityContainsCoordinate:coordinate] == NO) {
        [self setViewToStateClear];
        [self.viewCategoryMainView.categorySlider clearAllSurgeAreas];
        [[RARideRequestManager sharedManager] riderHasSelectedPickUpLocation:nil];
        [self makeSelectionRestrictedAndShowNotAvailableLabel];
        [self selectSource:coordinate address:address visibleAddress:visibleAddress isAvailable:NO zipCode:zipCode];
        
        if (self.isDestinationLocationSelected) {
            RARideLocationDataModel *destinationLocation = [[RARideRequestManager sharedManager] currentRideRequest].endLocation;
            [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:destinationLocation.coordinate];
            [self.btDestinationAddress setText:destinationLocation.visibleAddress];
        }
        completion(YES);
    } else {
        if (self.isStartLocationSelected) {
            CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            
            [self checkCurrentLocationDistanceToPickup:pickupLocation withHandler:^(BOOL confirmed) {
                if (confirmed) {
                    [weakself selectSource:coordinate address:address visibleAddress:visibleAddress isAvailable:YES zipCode:zipCode];
                    [weakself hideNotAvailabelLabelAndMakeSelectionAllowed];
                }
                completion(confirmed);
            }];
            
        } else {
            [self selectSource:coordinate address:address visibleAddress:visibleAddress isAvailable:YES zipCode:zipCode];
            [self hideNotAvailabelLabelAndMakeSelectionAllowed];
            completion(YES);
        }
    }
}

- (void)selectSource:(CLLocationCoordinate2D)coordinate address:(NSString*)address visibleAddress:(NSString*)visibleAddress isAvailable:(BOOL)available zipCode:(NSString *)zipCode {
    RAAddress *raAddress = [[RAAddress alloc] init];
    raAddress.address = address;
    raAddress.visibleAddress = visibleAddress;
    raAddress.zipCode = zipCode;
    
    [self updateCurrentLocation:coordinate withAddress:raAddress];
    
    if (self.btPickupAddress.isFirstResponder == NO) {
        self.btPickupAddress.text = self.currentLocation.visibleAddress;
    }

    if ([self isStartLocationSelected]) {
        [self.googleMapsManager createOrUpdatePickupMarkerWithCoordinate:coordinate];
        [self.googleMapsManager animateCameraToCoordinate:coordinate zoom:18];
        [[RARideRequestManager sharedManager] riderHasSelectedPickUpLocation:self.currentLocation];
    }
    
    self.pickUpCommentTextField.text = [[RARideCommentsManager sharedManager] commentFromLocation:self.currentLocation.coordinate];
        
    if (available) {
        if (![[RARideManager sharedManager] isOnTrip]) {
            [self showHUD];
            __weak LocationViewController *weakSelf = self;
            [self checkSurgeAvailabilityForLocation:coordinate withCompletion:^(NSError *error) {
                [weakSelf hideHUD];
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error
                                                andOptions:[RAAlertOption optionWithState:StateActive]];
                }

                [weakSelf startPollingForActiveDrivers];
                
                if (![[RARideManager sharedManager] isDriverComing] && [self isDestinationLocationSelected]) {
                    if([self isStartLocationSelected]){
                        [self showPins];
                    } else {
                        [weakSelf.googleMapsManager animateCameraToFitStartCoordinate:self.currentLocation.coordinate endCoordinate:self.currentRideRequest.endLocation.coordinate withEdgeInsets:self.insetsForMap];
                    }
                } else {
                    [weakSelf.googleMapsManager animateCameraToCoordinate:coordinate zoom:kDefaultMapZoom];
                }
                
                //Setting flag after some time because of previous animation
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    self.settingSource = NO;
                });

            }];
        } else {
            self.settingSource = NO;
        }
    } else {
        self.btDestinationAddress.text = @"";
        
        self.currentRideRequest.endLocation = nil;
        
        [self performRideStatusChangedTo:RARideStatusNone];
        
        //[self.btDestinationAddress setEnabled:NO];
        
        [self.googleMapsManager animateCameraToCoordinate:coordinate zoom:kDefaultMapZoom];
        
        //Setting flag after some time because of previous animation
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            self.settingSource = NO;
        });
    }
}

- (void)selectDestination:(CLLocationCoordinate2D)coordinate address:(NSString*)address visibleAddress:(NSString*)visibleAddress zipCode:(NSString *)zipCode {
    RARideLocationDataModel *previousLocation = self.preselectedDestination;
    
    self.btDestinationAddress.text = visibleAddress;
    
    RARideLocationDataModel *location = [RARideLocationDataModel new];
    location.address = address;
    location.visibleAddress = visibleAddress;
    location.latitude = [NSNumber numberWithDouble: coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble: coordinate.longitude];
    location.timestamp = [NSDate date];
    location.zipCode = zipCode;
    
    self.preselectedDestination = location;
    [[RARideRequestManager sharedManager] riderHasSelectedDestinationLocation:location];
    
    [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:coordinate];
    if (![[RARideManager sharedManager] isDriverComing]) {
        [self showPins];
    }
    
    if (![[RARideManager sharedManager] isOnTrip]) {
        [self showCommentsField];
    }

    BOOL equalCoordinate = [RARideManager rideCoordinate:self.preselectedDestination.coordinate isEqualToOtherRideCoordinate:previousLocation.coordinate];
    if ([[RARideManager sharedManager] isRiding] && !equalCoordinate) {
        [self changeDestination];
    }
}
 
- (void)changeDestination {

    //RA-3346
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        self.needsToResendDestinationChanged = YES;
        return;
    }
    
    if (self.currentRide.modelID) {
        self.needsToResendDestinationChanged = NO;
        
        RARideLocationDataModel *endLocation = [[[[RARideRequestManager sharedManager] currentRideRequest] endLocation] copy];
        if (!endLocation || ![endLocation.location isValid] || IS_EMPTY(endLocation.address)) {
            [RAAlertManager showErrorWithAlertItem:[@"Couldn't change destination, try again later." localized] andOptions:nil];
            return;
        }

        [[RARideManager sharedManager] pauseRidePolling];

        RARideLocationDataModel *previousEndLocation = [self.currentRide endLocation];

        __weak LocationViewController *weakSelf = self;
        [self showHUD];
        [[RARideManager sharedManager] updateDestination:endLocation completion:^(NSError *error) {
            [weakSelf hideHUD];
            
            AudioServicesPlaySystemSound(1005);
            if (error) {
                BFLogErr(@"Destination updated with error: %@", error);
                //Restore previous location in case of error
                [[RARideRequestManager sharedManager] riderHasSelectedDestinationLocation:previousEndLocation];
                weakSelf.preselectedDestination = previousEndLocation;
                [weakSelf.currentRide setEndLocation:previousEndLocation];
                
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            } else {
                BFLog(@"Destination updated");
                weakSelf.riderChangedDestination = YES;
                [weakSelf.currentRide updateObservedDestinationWithEndLocation:endLocation]; //this forces to the observed value to send the notification and so update the view immediately instead of waiting until next request of ride polling (currerntly max time is 2 secs). No need to update view here. In fact it was causing issues.
            }
            
            dispatch_async(getUtilityQueue(), ^{
                [[RARideManager sharedManager] resumeRidePolling];
            });
        }];
    }
}

- (void)checkSurgeAvailabilityForLocation:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)(NSError *error))handler {
    __weak LocationViewController *weakSelf = self;
    [RASurgeAreaAPI getSurgeAreasAtCoordinate:coordinate withCompletion:^(NSArray<RASurgeAreaDataModel *> *surgeAreas, NSError *error) {
        if (!error) {
            [weakSelf.viewCategoryMainView.categorySlider clearSurgeAreas:surgeAreas];
            [weakSelf processSurgeAreas:surgeAreas withCompletion:nil];
        }
        
        if (handler) {
            handler(error);
        }
    }];
}

- (void)resetAndGetActiveDrivers {
    [self.viewSetPickupLocation showLoadingAnimation];
    [self startPollingForActiveDrivers];
}

- (void)updatePaymentDeficiencyView {
    [self.mainCoordinator showPaymentDeficiencyInViewController:self];
}

- (void)deleteRideShowingAlert {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSString.accessibleAlertTitleRideAustin message:[@"Do you really want to cancel the trip?" localized] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self attemptToCancelRide];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:no];
    [ac addAction:yes];
    
    [self.navigationController presentViewController:ac animated:YES completion:nil];
}

- (void)attemptToCancelRide {
    if (!self.currentRide.modelID) {
        if ([self currentRideRequest]) {
            [self performRideStatusChangedTo:RARideStatusPrepared];
        } else {
            [self performRideStatusChangedTo:RARideStatusNone];
        }
        return;
    }
    
    if ([[RARideManager sharedManager] isOnTrip]) {
        [RAAlertManager showAlertWithTitle:[NSString accessibleAlertTitle:[@"Too Late" localized]] message:[@"The driver has started the trip. You cannot cancel after the trip has started." localized]];
        return;
    }
    
    [self showHUD];
    __block NSString *rideID = self.currentRide.modelID.stringValue;
    __weak LocationViewController *weakSelf = self;
    [[RARideManager sharedManager] cancelRideWithId:rideID completion:^(NSError *error) {
        if (!error) {
            [RARideAPI getRide:rideID withRiderLocation:[LocationService myValidLocation] andCompletion:^(RARideDataModel *ride, NSError *error) {
                [weakSelf hideHUD];
                [weakSelf.mainCoordinator navigateToGetFeedbackForRide:ride orError:error];
            }];
            
            if ([weakSelf currentRideRequest]) {
                [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
            } else {
                [weakSelf performRideStatusChangedTo:RARideStatusNone];
            }
            
        } else {
            [weakSelf hideHUD];
            if (![error.localizedRecoverySuggestion containsString:@"Ride state is not found"]) {
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            }
        }
    }];
}

- (void)processRequestRideAction {
    [self performRideStatusChangedTo:RARideStatusRequesting];
    __weak LocationViewController *weakSelf = self;
    [RASurgeAreaAPI getSurgeAreasAtCoordinate:self.currentRideRequest.startLocation.coordinate withCompletion:^(NSArray<RASurgeAreaDataModel *> *surgeAreas, NSError *error) {
        if (!error) {
            [weakSelf.viewCategoryMainView.categorySlider clearSurgeAreas:surgeAreas];
            [weakSelf processSurgeAreas:surgeAreas withCompletion:^{
                //Proceed with the request
                [weakSelf processRequest];
            }];
        } else {
            [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)processRequest {
    if ([self.selectedCategory hasPriority]) {
        PriorityFareConfirmationViewController *priorityFareConfirmationViewController = [[PriorityFareConfirmationViewController alloc] initWithCategory:self.selectedCategory];
        
        __weak LocationViewController *weakSelf = self;
        priorityFareConfirmationViewController.handler = ^(BOOL accepted){
            if (accepted) {
                [weakSelf requestRide];
            } else {
                [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
            }
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:priorityFareConfirmationViewController];
        
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        [self requestRide];
    }
}

- (void)requestRide {
    
    self.isDriverComingShown = NO;
    
    RARideRequest *rideRequest = self.currentRideRequest;
    
    if (rideRequest.startLocation.latitude && rideRequest.startLocation.longitude) {
        
        [self performRideStatusChangedTo:RARideStatusRequesting];

        [[RARideRequestManager sharedManager] riderHasSelectedCategory:self.selectedCategory];
        rideRequest.womanOnlyMode = [[RARideRequestManager sharedManager] isWomanOnlyModeOn];
        if (!rideRequest.comment && self.pickUpCommentTextField.text) {
            [[RARideRequestManager sharedManager] riderHasWrittenPickUpComment:self.pickUpCommentTextField.text];
        }
        
        RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
        if (rider.preferredPaymentMethod == PaymentMethodBevoBucks) {
            rideRequest.paymentProvider = @"BEVO_BUCKS";
        }
        
        [rideRequest storeComment];
        
        __weak LocationViewController *weakSelf = self;
        [[RARideManager sharedManager] requestRide:rideRequest completion:^(NSInteger statusCode, RARideDataModel *ride, NSError *error) {
            if (!error) {
                [weakSelf performRideStatusChangedTo:ride.status];
            } else {
                
                //Check if user has pending balance
                const NSInteger kUnpaidRideStatusCode = 402;
                if (statusCode == kUnpaidRideStatusCode) {
                    [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
                    [weakSelf updatePaymentDeficiencyView];
                    [weakSelf.mainCoordinator navigateToPaymentMethodList];
                    return;
                }
                
                //if exists a ride then we have to show alert to cancel it or restore it. If no then show an alert with the server error.
                [RARideAPI getCurrentRideWithCompletion:^(RARideDataModel *ride, NSError *currentRideError) {
                    [weakSelf hideHUD];
                    if (ride) {
                        [weakSelf handleRideRestoration:ride];
                    } else {
                        [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
                        NSError *alertError = currentRideError ? currentRideError : error;
                        [RAAlertManager showErrorWithAlertItem:alertError
                                                    andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                    }
                }];
            }
        }];
        
    } else {//This should never happen but could.
        [self performRideStatusChangedTo:RARideStatusNone];
        RAAlertOption *option = [RAAlertOption optionWithState:StateActive andShownOption:Overlap];
        [RAAlertManager showAlertWithTitle:@"" message:[@"Sorry something went wrong, please set pick up location again." localized] options:option];
    }
}

- (void)handleRideRestoration:(RARideDataModel *)ride {
    __weak LocationViewController *weakSelf = self;
    
    RAAlertOption *options = [RAAlertOption optionWithState:StateAll];
    
    [options addAction:[RAAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        [weakSelf performRideStatusChangedTo:RARideStatusNone];
        [RARideAPI cancelRideById:ride.modelID.stringValue withCompletion:^(NSError *error) {
            if (error){
                [weakSelf synchronizeRideWithCompletion:nil];
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            }
        }];
    }]];
    
    [options addAction:[RAAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
        [[RARideManager sharedManager] restoreRide:ride.modelID.stringValue completion:^(RARideDataModel *ride, NSError *error) {
            if (error) {
                [weakSelf synchronizeRideWithCompletion:nil];
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive]];
            } else if (ride) {
                [weakSelf performRideStatusChangedTo:ride.status];
            }
        }];
    }]];
    
    [RAAlertManager showAlertWithTitle:[@"Appears you have an existing Ride" localized] message:[@"Do you want to cancel it?" localized] options:options];
}

- (void)handleCancelRideWithMessage:(NSString *)message {
    [self.tripCancellationAlert dismiss];
    [RAAlertManager showAlertWithTitle:[NSString accessibleAlertTitle:[@"TRIP WAS CANCELLED" localized]]
                               message:message
                               options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
}

- (UIEdgeInsets)insetsForMap {
    UIEdgeInsets padding = [self.googleMapsManager getPadding];
    CGFloat viewAddressFieldsHeight = CGRectGetHeight(self.viewPickupField.frame) + CGRectGetHeight(self.viewPickupField.frame) + 50 - 9 - 9; //can't use realtime self.viewAddress height because it is adjusted during animation from pickerAddressViewController
    CGFloat pinHeight = 45;
    CGFloat verticalMargin = 5;
    CGFloat horizontalMargin = 15;
    CGFloat insertingViewHeight = 54;
    CGFloat topInset =  10 + insertingViewHeight + viewAddressFieldsHeight + pinHeight*0.7 + verticalMargin;
    
    CGFloat bottomInset = verticalMargin + CGRectGetHeight(self.viewRequestRide.frame) + kMainMarginBottom - padding.bottom;
    if (@available(iOS 11.0, *)) {
        bottomInset += self.view.safeAreaInsets.bottom/2.0;
        topInset    += self.view.safeAreaInsets.bottom/2.0;
    }
    return UIEdgeInsetsMake(topInset, horizontalMargin, bottomInset, horizontalMargin);
}

- (BOOL)isFarLocation:(CLLocation *)location fromPickup:(CLLocation *)pickupLocation{
    CLLocationDistance distance = location ? [location distanceFromLocation:pickupLocation] : 0.0;
    return distance >= [ConfigurationManager shared].global.ridesConfig.distanceToAskPickupPrompt.doubleValue;
}

- (void)checkCurrentLocationDistanceToPickup:(CLLocation *)pickupLocation withHandler:(__nonnull ConfirmedDistanceBlock)handler{
    __weak LocationViewController *weakself = self;
    [self getMyCurrentLocationWithCompletion:^(CLLocation *location, NSError *error) {
        if (!error && [weakself isFarLocation:location fromPickup:pickupLocation]) {
            [weakself showConfirmationAlertWithHandler:^(BOOL confirmed) {
                handler(confirmed);
            }];
        } else {
            handler(YES);
        }
    }];
}

- (void)showConfirmationRequestViewSavingPickUp:(BOOL)shouldSavePickup{
    [self.view endEditing:YES];

    __weak LocationViewController *weakSelf = self;
    void(^requestViewPickupCompletion)(RARideLocationDataModel *location) = ^(RARideLocationDataModel *location){
        if (shouldSavePickup) {
            RARecentPlace *recentPlace = [[RARecentPlace alloc]init];
            recentPlace.name = location.address;
            recentPlace.shortAddress = location.address;
            recentPlace.fullAddress = location.completeAddress;
            recentPlace.coordinate = location.coordinate;
            [RARecentPlacesManager addRecentPlace:recentPlace];
        }
        
        [[RARideRequestManager sharedManager] riderHasSelectedPickUpLocation:location];
        if (weakSelf.preselectedDestination) {
            [[RARideRequestManager sharedManager] riderHasSelectedDestinationLocation:weakSelf.preselectedDestination];
        }
        
        if (weakSelf.preselectedComment) {
            [[RARideRequestManager sharedManager] riderHasWrittenPickUpComment:weakSelf.preselectedComment];
        }
        
        [weakSelf performRideStatusChangedTo:RARideStatusPrepared];
    };
    
    if (!self.currentLocation.address) {
        [self showHUD];
        [[GeocoderService sharedInstance] reverseGeocodeForCoordinate:self.currentLocation.coordinate completion:^(RAAddress * _Nullable address, NSError * _Nullable error) {
            [weakSelf hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:[@"Sorry we could not determine your location." localized] andOptions:[RAAlertOption optionWithState:StateActive]];
            } else {
                [weakSelf updateCurrentLocation:weakSelf.currentLocation.coordinate withAddress:address];
                requestViewPickupCompletion(weakSelf.currentLocation);
            }
        }];
    } else {
        requestViewPickupCompletion(self.currentLocation);
    }
}

- (void)updateCurrentLocation:(CLLocationCoordinate2D)coordinate withAddress:(RAAddress *)address{
    
    NSString *addressValue = address.address ? address.address : address.fullAddress;
    
    RARideLocationDataModel *loc = [[RARideLocationDataModel alloc] initWithCoordinate:coordinate];
    loc.address = addressValue;
    loc.visibleAddress = address.visibleAddress ? address.visibleAddress : addressValue;
    loc.timestamp = [NSDate date];
    loc.zipCode = address.zipCode;
    
    self.currentLocation = loc;
    self.preselectedSource = loc;
}

NSString *const kErrorLocationNotFound = @"com.rideaustin.location.not.found";

- (void(^)(NSError* _Nullable))currentLocationDefaultHandler {
    __weak LocationViewController *weakSelf = self;
    return ^(NSError *error) {
        
        [weakSelf dismissKeyboard];
        [weakSelf.viewSetPickupLocation enableSetPickUpButton];
        weakSelf.btFindLocation.enabled = YES;
        
        if (error && weakSelf.isViewLoaded && weakSelf.view.window) {
            if ([error.domain isEqualToString:kErrorLocationNotFound]) {
                [RAAlertManager showAlertWithTitle:[@"Location not found" localized] message:[@"Sorry, could not find your current location" localized]];
            } else {
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive]];
            }
        }
    };
}

- (void)moveToCurrentLocationWithCompletion:(void(^)(NSError *))completion {
    if ([self isSettingSource]) {
        return;
    }
    
    [self.viewSetPickupLocation disableSetPickUpButton];
    
    __weak LocationViewController *weakSelf = self;
    NSError *locationError = [NSError errorWithDomain:kErrorLocationNotFound code:-1 userInfo:nil];
    [self getMyCurrentLocationWithCompletion:^(CLLocation *location, NSError *error) {
        
        if (error || weakSelf.isSettingSource) {
            if (completion) {
                completion(error ? locationError : nil);
            }
            return;
        }
        
        //Clean the startAddress
        if (![[RARideManager sharedManager] isRiding]) {
            [self.btPickupAddress setText:@""];
        } else {
            if (completion) {
                completion(nil);
            }
            return;
        }
        
        [weakSelf.googleMapsManager animateCameraToCoordinate:location.coordinate
                                                         zoom:kDefaultMapZoom];
        
        //Geocode Address
        [[GeocoderService sharedInstance] reverseGeocodeForCoordinate:location.coordinate completion:^(RAAddress * _Nullable address, NSError * _Nullable error) {
            if (error || weakSelf.isSettingSource) {
                
                if (error) { //Restrict pin selection, as we don't get address
                    [weakSelf makeSelectionRestrictedAndShowNotAvailableLabel];
                }
                
                if (completion) {
                    completion(error ? locationError : nil);
                }
                return;
            }
            
            //Reload Models & UI
            [weakSelf updateCurrentLocation:location.coordinate withAddress:address];
            [weakSelf reloadCategories];
            
            if (weakSelf.btPickupAddress.isFirstResponder == NO) {
                weakSelf.btPickupAddress.text = weakSelf.currentLocation.visibleAddress;
            }
            
            if (weakSelf.isStartLocationSelected && ![weakSelf.viewRequestRide isHidden]) {
                [weakSelf.googleMapsManager createOrUpdatePickupMarkerWithCoordinate:location.coordinate];
                [weakSelf.googleMapsManager animateCameraToCoordinate:location.coordinate zoom:18];
                [[RARideRequestManager sharedManager] riderHasSelectedPickUpLocation:weakSelf.currentLocation];
            }
            
            //Validate ZipCode Availability
            if (![ConfigurationManager currentCityContainsCoordinate:location.coordinate]) {
                [weakSelf makeSelectionRestrictedAndShowNotAvailableLabel];
                if (completion) {
                    completion(nil);
                }
                return;
            }
            
            //Pickup Available
            [weakSelf hideNotAvailabelLabelAndMakeSelectionAllowed];
            
            //Rider in a trip, avoid reloading surgeAreas
            if ([[RARideManager sharedManager] isOnTrip]) {
                if (completion) {
                    completion(nil);
                }
                return;
            }
            
            [weakSelf checkSurgeAvailabilityForLocation:location.coordinate withCompletion:^(NSError *error) {
                [weakSelf startPollingForActiveDrivers];
            }];
            
            if (completion) {
                completion(nil);
            }
        }];
    }];
    
}

@end

@implementation LocationViewController (TTTAttributedLabelDelegate)

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end


@implementation LocationViewController (RequestRideViewDelegate)

- (void)requestRideView:(RequestRideView *)requestRideView didTapFareEstimate:(UIButton *)sender {
    [self didTapFareEstimate:sender];
}

- (void)requestRideView:(RequestRideView *)requestRideView didTapCancel:(UIButton *)sender {
    [[RARideRequestManager sharedManager] deleteRideRequest];
    [self.googleMapsManager removeTripMarkers];
    [self hideCommentsField];
    self.btDestinationAddress.text = @"";
    self.preselectedDestination = nil;
    self.preselectedComment = nil;
    [self performRideStatusChangedTo:RARideStatusNone];
    [self showRoundUpAlertIfNeeded];
}

- (void)requestRideView:(RequestRideView *)requestRideView didTapRequestRide:(UIButton *)sender {
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        [self showOfflineMessageViewWithMessage:[@"No internet connection." localized]];
        return;
    }
    
    // make sure the user did not clear the source or destination.
    // shouldn't it be better to check start and end location?
    [self.view endEditing:YES];
    __weak LocationViewController *weakself = self;
    if (self.btPickupAddress.text.length == 0) {
        [self performRideStatusChangedTo:RARideStatusNone];
        RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
        [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
            if (UIAccessibilityIsVoiceOverRunning()) {
                [weakself.btPickupAddress becomeFirstResponder];
            }
        }]];
        [RAAlertManager showAlertWithTitle:[NSString accessibleAlertTitle:[@"Missing Address" localized]]
                                   message:[@"Please enter a pickup address" localized]
                                   options:option];
    } else {
        void(^requestActionsBlock)(void) = ^{
            RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
            if (rider.preferredPaymentMethod == PaymentMethodApplePay) {
                [[ApplePayHelper sharedInstance] showApplePayAuthorizationWithCategory:self.selectedCategory completion:^(NSString *token, NSError *error) {
                    if ([error.domain isEqualToString:kApplePaymentInvalidDomainError]) {
                        [RASessionManager sharedManager].currentRider.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
                        [weakself.mainCoordinator navigateToPaymentMethodList];
                    } else if (token) {
                        weakself.currentRideRequest.applePayToken = token;
                        [weakself checkForHintsWithCompletion:^(BOOL shouldProceed) {
                            if (shouldProceed) {
                                [weakself processRequestRideAction];
                            }
                        }];
                    }
                }];
            } else {
                [weakself.currentRideRequest cleanupApplePayToken];
                [weakself checkForHintsWithCompletion:^(BOOL shouldProceed) {
                    if (shouldProceed) {
                        [weakself processRequestRideAction];
                    }
                }];
            }
        };
        if ([self shouldShowNotificationPermission]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastDatePermissionShownKey];
            RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
            [option addAction:[RAAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                requestActionsBlock();
            }]];
            [option addAction:[RAAlertAction actionWithTitle:[@"Allow" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                id appDelegate = UIApplication.sharedApplication.delegate;
                if ([appDelegate respondsToSelector: @selector(registerForNotifications)]) {
                    [appDelegate registerForNotifications];
                }
                requestActionsBlock();
            }]];
            [RAAlertManager showAlertWithTitle:[@"Allow Push Notifications?" localized] message:[@"You will be notified when you get a driver or when a driver arrives to your location" localized] options:option];
        }
        else {
            requestActionsBlock();
        }
    }
}
/***
//if coordinate is equal to hint,
    // completion(YES)
//if pickup is not a hint, then
    // completion(YES)
//if pickup is inside polygon, and pickup is near a hint
    //Then show location picker
        // if picker cancelled
            // completion(NO)
        // if picker succeeded,
            // [[RARideRequestManager sharedManager] riderHasSelectedPickUpLocation:location];
            // make sure that pickup field and the request sends the new coordinate with address -- server will attach the hint name so no need to add it in the request
            // completion(YES)
*/
- (void)checkForHintsWithCompletion:(void (^)(BOOL shouldProceed))completion {
    __weak __typeof__(self) weakself = self;
    ConfigGlobal *global = [ConfigurationManager shared].global;
    NSArray<RAPickupHint *> *pickupHints = global.geocoding.pickupHints;
    //guard
    if (pickupHints == nil || pickupHints.count == 0) {
        completion(YES);
        return;
    }
    
    //check if coordinate is equal to hint
    for (RAPickupHint * hint in pickupHints) {
        for (RADesignatedPickup * pickup in hint.designatedPickups) {
            if ([pickup.driverCoord.location isEqualToOtherLocation:self.currentRideRequest.startLocation.location]) {
                completion(YES);
                return;
            }
        }
    }
    
    void(^locationPickerCompletion)(RAPickerAddressFieldType, RARideLocationDataModel *, BOOL) = ^(RAPickerAddressFieldType fieldType, RARideLocationDataModel *location, BOOL isSelected) {
        if (isSelected) {
            [weakself updateAddressWithHint:location andAddressType:fieldType];
            completion(YES);
        }
        else {
            completion(NO);
        }
    };
    
    //check if pickup is inside polygon, and pickup is near a hint
    for (RAPickupHint *pickupHint in pickupHints) {
        if ([pickupHint containsCoordinate:self.currentRideRequest.startLocation.coordinate]) {
            LocationPickerViewController * picker = [[LocationPickerViewController alloc] initWithFieldType:RAPickerAddressPickupFieldType completion:locationPickerCompletion];
            [self.navigationController pushViewController:picker animated:YES];
            return;
        }
        else {
            // TODO: Destination hints not considered in guard above
        }
    }
    completion(YES);
}

-(void)updateAddressWithHint:(RARideLocationDataModel *)location andAddressType:(RAPickerAddressFieldType) type {
    
    switch (type) {
        case RAPickerAddressPickupFieldType:
             [[RARideRequestManager sharedManager]
              riderHasSelectedPickUpLocation:location];
            break;
        case RAPickerAddressDestinationFieldType:
              [[RARideRequestManager sharedManager]
               riderHasSelectedDestinationLocation:location];
            break;

    }
}

- (BOOL)shouldShowNotificationPermission {
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDateShown =  (NSDate*)[defaults objectForKey:kLastDatePermissionShownKey];
    if (!lastDateShown) {
        return YES;
    }
    
    NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:lastDateShown];
    return (timeElapsed > kTimeToShowPermission);
}

@end

@implementation LocationViewController (BottomDrawerViewDelegate)

- (void)drawerView:(BottomDrawerView *)drawerView didSwipe:(UISwipeGestureRecognizerDirection)swipeDirection {
    if (swipeDirection == UISwipeGestureRecognizerDirectionUp) {
        [self expandViewCategoryMainView];
    } else {
        [self collapseViewCategoryMainView];
    }
}

- (void)drawerView:(BottomDrawerView *)drawerView didTapGetRideEstimate:(UIButton *)sender {
    [self didTapFareEstimate:sender];
}

- (void)drawerView:(BottomDrawerView *)drawerView didTapViewPricing:(UIButton *)sender {
    sender.enabled = NO;
    RARideRequest *rideRequest = self.currentRideRequest;
    [self showHUD];
    CLLocationCoordinate2D pickupCoordinate = self.googleMapView.camera.target;
    if (rideRequest.startLocation.location.isValid) {
        pickupCoordinate = rideRequest.startLocation.coordinate;
    }
    
    __weak __typeof__(self) weakself = self;
    [RARideAPI getSpecialFeesAtCoordinate:pickupCoordinate
                                   cityID:[ConfigurationManager shared].global.currentCity.cityID
                           forCarCategory:self.selectedCategory.carCategory
                           withCompletion:^(NSArray<RAFee *> * _Nullable specialFees, NSError * _Nullable error) {
                               sender.enabled = YES;
                               [weakself hideHUD];
                               if (error) {
                                   [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                               } else {
                                   RideCostDetailViewController *vc = [RideCostDetailViewController controllerWithCarCategory:weakself.selectedCategory andSpecialFees:specialFees];
                                   [vc showInParent:self];
                               }
                           }];
}

- (void)drawerView:(BottomDrawerView *)drawerView didTapChevron:(UIButton *)sender {
    [self toggleViewCategoryMainView];
}

- (void)drawerView:(BottomDrawerView *)drawerView didChangeSelectedCategory:(RACarCategoryDataModel *)selectedCategory {
    if (self.currentSelectedCarCategory != selectedCategory) {
        self.currentSelectedCarCategory  = selectedCategory;
        
        [[RARideRequestManager sharedManager] riderHasSelectedCategory:self.currentSelectedCarCategory];
        
        BOOL shouldShowAlert = selectedCategory.configuration.showAlert;
        if (shouldShowAlert){
            RASimpleAlertView *simpleAlertView = [RASimpleAlertView simpleAlertViewWithTitle:[selectedCategory.title stringByReplacingOccurrencesOfString:@"\n" withString:@""] andMessage:selectedCategory.catDescription];
            simpleAlertView.lblMessage.delegate = self;
            [simpleAlertView show];
        }
    }
    [self.viewCategoryMainView updateLabelsWithPickupETA:self.currentActiveDriverETA];
    [self resetAndGetActiveDrivers];
}

@end

@implementation LocationViewController (DriverInfoViewDelegate)

- (void)driverInfoView:(DriverInfoView *)driverInfoView didTapCancelWithCompletion:(void (^)(void))completion {
    if ([[RARideManager sharedManager] isOnTrip]) {
        [RAAlertManager showAlertWithTitle:[NSString accessibleAlertTitle:[@"Invalid" localized]] message:[@"You cannot cancel while on trip." localized]];
        completion();
        return;
    }
    
    if (self.currentRide.requestedCarType &&
        self.currentRide.requestedCarType.hasCancellationFee == NO) {
        [self showCancellationAlertWithLine1:[@"Do you really want to cancel the trip?" localized] line2:nil line3:nil];
        completion();
        return;
    }
    
    //avoid display the alert already displayed
    if ([self.tripCancellationAlert isVisible]) {
        completion();
        return;
    }
    
    NSDate *freeCancellationExpiryDate = self.currentRide.freeCancellationExpiryDate;
    if (!freeCancellationExpiryDate) {
        [self showCancellationAlertWithLine1:[@"Do you really want to cancel the trip?" localized] line2:nil line3:nil];
    } else {
        NSTimeInterval remainingTime = freeCancellationExpiryDate.timeIntervalSinceNow;
        NSNumber *cancellationFee = self.currentRide.requestedCarType.cancellationFee;
        
        BOOL isCancellationPeriodWithoutFeeExpired = remainingTime <= 0;
        if (isCancellationPeriodWithoutFeeExpired) {
            [self showCancellationAlertWithLine1:[@"You will be charged" localized] line2:[NSString stringWithFormat:[@"$%.2f cancellation fee." localized], cancellationFee.doubleValue] line3:[@"Do you want to cancel the trip?" localized]];
            
        } else {
            NSString *secondsRemainingText = [NSString stringWithFormat:[@"You have %lu seconds to cancel the ride without being charged. After that you will be charged" localized],(long)remainingTime];
            [self showCancellationAlertWithLine1:secondsRemainingText line2:[NSString stringWithFormat:[@"$%.2f cancellation fee." localized],cancellationFee.doubleValue] line3:[@"Do you want to cancel the trip?" localized]];
            [self setupTripCancellationTimer];
        }
    }
    completion();
}

- (void)driverInfoView:(DriverInfoView *)driverInfoView didTapFareEstimate:(UIButton *)sender {
    [self didTapFareEstimate:sender];
}

- (void)driverInfoView:(DriverInfoView *)driverInfoView willResizeWithVisibleHeight:(CGFloat)visibleHeight {
    self.constraintViewDriverTopToSuperViewBottom.constant = -visibleHeight;
}
@end

@implementation LocationViewController (AddressContainerAnimationProtocol)

- (void)setAddressContainerTopConstraint:(CGFloat)constant {
    self.constraintAddressContainerTop.constant = constant;
}
- (void)setAddressContainerLeadingTrailingConstraint:(CGFloat)constant {
    self.constraintAddressContainerLeading.constant = constant;
    self.constraintAddressContainerTrailing.constant = constant;
}
- (void)setDestinationFieldTopConstraint:(CGFloat)constant {
    self.constraintDestinationFieldTop.constant = constant;
}
- (void)setCommentFieldTopConstraint:(CGFloat)constant {
    self.constraintCommentFieldTop.constant = constant;
}

@end

