//
//  DCDriverDetailViewController.m
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DCDriverDetailViewController.h"

#import "ApplePayHelper.h"
#import "CategoryChooserViewController.h"
#import "DCDriverDetailViewModel.h"
#import "GeocoderService.h"
#import "LocationService.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "PaymentViewController.h"
#import "RAButton.h"
#import "RADirectConnectRideRequest.h"
#import "RAPaymentHelper.h"
#import "RARideAPI.h"
#import "RARideManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

typedef void(^RequestRideBlock)(NSString *applePayToken);

@interface DCDriverDetailViewController () <CategoryChooserDelegate>

//IBOutlets
//Driver Information
@property (weak, nonatomic) IBOutlet UIImageView *imgDriver;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverRating;

//Current Category
@property (weak, nonatomic) IBOutlet UIImageView *imgCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryName;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgPriority;
@property (weak, nonatomic) IBOutlet UILabel *lblPriority;
@property (weak, nonatomic) IBOutlet UIImageView *imgCategoryChevron;

//Card Information
@property (weak, nonatomic) IBOutlet UIImageView *imgCard;
@property (weak, nonatomic) IBOutlet UILabel *lblCard;

//Loading Container
@property (weak, nonatomic) IBOutlet UIView *loadingContainer;

@property (weak, nonatomic) IBOutlet RAButton *btnRequestRide;

//Properties
@property (strong, nonatomic) DCDriverDetailViewModel *driverDetailViewModel;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIAlertController *cancelRideRequestAlert;

@end

@implementation DCDriverDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRideManagerObserver];
    self.driverDetailViewModel = [[DCDriverDetailViewModel alloc] initWithDriverDirectConnect:self.driverDirectConnectDataModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupDesign];
}

- (void)dealloc {
    [[RARideManager sharedManager] removeObserver:[self KVOController]];
}

#pragma mark - Configure UI

- (void)setupDesign {
    [self configureBackButton];
    [self configureDriverProfile];
    [self configureCarCategory];
    [self configurePaymentMethod];
}

- (void)configureBackButton {
    //Wrapped in container to adjust margin with system button position
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(-200, 0, 40, 40)];

    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setFrame:CGRectMake(-25, 2, 45, 40)];
    [customButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [customButton setImage:[UIImage imageNamed:@"back-icon"] forState:UIControlStateNormal];
    [containerView addSubview:customButton];
    
    self.backButton = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.leftBarButtonItem = self.backButton;
}

- (void)configureDriverProfile {
    [self.imgDriver sd_setImageWithURL:self.driverDetailViewModel.driverPhotoUrl placeholderImage:[UIImage imageNamed:@"person_placeholder"]];
    self.lblDriverName.text = self.driverDetailViewModel.driverFullName;
    self.lblDriverRating.text = self.driverDetailViewModel.driverRating;
}

- (void)configureCarCategory {
    RACarCategoryDataModel *category = self.driverDetailViewModel.category;
    if (category) {
        self.lblCategoryName.text = category.title;
        self.lblCategoryDescription.text = self.driverDetailViewModel.numberOfSeats;
        [self.imgCategory sd_setImageWithURL:category.plainIconUrl placeholderImage:nil];
        self.lblPriority.text = self.driverDetailViewModel.priority;
        self.lblPriority.hidden = !self.driverDetailViewModel.shouldShowPriority;
        self.imgPriority.hidden = !self.driverDetailViewModel.shouldShowPriority;
    }
}

- (void)configurePaymentMethod {
    PaymentItem *paymentItem = [RAPaymentHelper selectedPaymentMethod];
    self.imgCard.image = paymentItem.iconItem;
    self.lblCard.text = paymentItem.text;
}

#pragma mark - Setup RideManager

- (void)setupRideManagerObserver {
    __weak DCDriverDetailViewController *weakSelf = self;
    [[RARideManager sharedManager] addObserver:[self KVOController] withHandler:^(FBKVOController *observer, NSDictionary<NSString *,id> *change) {
        NSString *keyPath = change[kRAObservationKeyPath];
        if ([keyPath isEqualToString:kRAKeyPathObserveCurrentRideStatus]) {
            id valueNew = change[kRAObservationNewValue];
            if ([valueNew isKindOfClass:[NSNumber class]]) {
                RARideStatus rideStatus = [valueNew integerValue];
                [[LocationService sharedService] updateLocationSettingsForStatus:rideStatus];
                
                if (weakSelf.cancelRideRequestAlert) {
                    [weakSelf.cancelRideRequestAlert dismissViewControllerAnimated:NO completion:nil];
                }
                
                switch (rideStatus) {
                    case RARideStatusRequested:
                        break;
                    case RARideStatusRiderCancelled:
                    case RARideStatusNoAvailableDriver: {
                        [UIView animateWithDuration:0.2 animations:^{
                            weakSelf.loadingContainer.alpha = 0.0;
                            [weakSelf updateRequestRideBtn];
                        }];
                        if (rideStatus == RARideStatusNoAvailableDriver) {
                            [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:[@"Driver did not accept your request" localized] options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
                        }
                        break;
                    }
                    case RARideStatusDriverAssigned:
                    default:
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShouldSynchronizeCurrentRide object:nil];
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        break;
                }
            }
        }
    }];
}

#pragma mark - IBActions

- (void)backButtonTapped:(id)sender {
    if ([[RARideManager sharedManager] currentRide]) {
        __weak DCDriverDetailViewController *weakSelf = self;
        RAAlertOption *options = [RAAlertOption optionWithState:StateActive andShownOption:Overlap];
        [options addAction:[RAAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nullable action) {
            [weakSelf cancelRequestTapped:nil];
        }]];
        
        [options addAction:[RAAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil]];
        
        self.cancelRideRequestAlert = [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:[@"Do you really want to cancel this ride?" localized] options:options];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)categoryChooserTapped:(id)sender {
    [self performSegueWithIdentifier:@"segue_DCDriverDetailViewController_CategoryChooserViewController" sender:nil];
}

- (IBAction)paymentMethodTapped:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] init];
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

- (IBAction)requestTapped:(id)sender {
    __weak DCDriverDetailViewController *weakSelf = self;
    
    //check location
    if ([self.delegate dcDriverDetailViewControllerCheckLocationPermissions:self] == NO) {
        return;
    }
    
    //check payment method
    RARiderDataModel *currentRider = [RASessionManager sharedManager].currentRider;
    if (currentRider.preferredPaymentMethod == PaymentMethodApplePay) {
        RACarCategoryDataModel *carCategory = self.driverDetailViewModel.category;
        [[ApplePayHelper sharedInstance] showApplePayAuthorizationWithCategory:carCategory completion:^(NSString *token, NSError *error) {
            if ([error.domain isEqualToString:kApplePaymentInvalidDomainError]) {
                currentRider.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
                [weakSelf paymentMethodTapped:nil];
            } else if (token) {
                [weakSelf requestRideBlock](token);
            }
        }];
    } else if (!currentRider.primaryCard) {
        if (currentRider.preferredPaymentMethod == PaymentMethodBevoBucks) {
            NSString *message = [@"To use Bevo Pay, please add a credit card as payment method" localized];
            [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateAll]];
        } else {
            NSString *message = [@"Please select payment method" localized];
            [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateAll]];
        }
    } else {
        [weakSelf requestRideBlock](nil);
    }
}

- (IBAction)cancelRequestTapped:(id)sender {
    RARideDataModel *currentRide = [[RARideManager sharedManager] currentRide];
    if (currentRide) {
        [self showHUD];
        __weak DCDriverDetailViewController *weakSelf = self;
        [[RARideManager sharedManager] cancelRideWithId:currentRide.modelID.stringValue completion:^(NSError *error) {
            [weakSelf hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
            } else {
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.loadingContainer.alpha = 0.0;
                    [weakSelf updateRequestRideBtn];
                }];
            }
        }];
    }
}

#pragma mark - Helpers

- (void)updateCancelBtn {
    [self.btnRequestRide removeTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventAllTouchEvents];
    [self.btnRequestRide addTarget:self action:@selector(cancelRequestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRequestRide setTitle:[@"CANCEL" localized] forState:UIControlStateNormal];
    [self.btnRequestRide setEnabled:NO];
}

- (void)updateRequestRideBtn {
    [self.btnRequestRide removeTarget:self action:@selector(cancelRequestTapped:) forControlEvents:UIControlEventAllTouchEvents];
    [self.btnRequestRide addTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRequestRide setTitle:[@"REQUEST DRIVER" localized] forState:UIControlStateNormal];
    [self.btnRequestRide setEnabled:YES];
}

- (RequestRideBlock)requestRideBlock {
    __weak DCDriverDetailViewController *weakSelf = self;
    return ^(NSString *applePayToken) {
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.loadingContainer.alpha = 1.0;
            [weakSelf updateCancelBtn];
            weakSelf.backButton.enabled = NO;
        } completion:^(BOOL finished) {
            
            CLLocation *currentLocation = [LocationService sharedService].myLocation;
            [[GeocoderService sharedInstance] reverseGeocodeForCoordinate:currentLocation.coordinate completion:^(RAAddress * _Nullable address, NSError * _Nullable error) {
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
                    [UIView animateWithDuration:0.2 animations:^{
                        weakSelf.loadingContainer.alpha = 0.0;
                        [weakSelf updateRequestRideBtn];
                        weakSelf.backButton.enabled = YES;
                    }];
                    return;
                }
                
                RADirectConnectRideRequest *directConnectRideRequest = [weakSelf.driverDetailViewModel directConnectRideRequestWithApplePayToken:applePayToken address:address];
                [[RARideManager sharedManager] requestRide:directConnectRideRequest completion:^(NSInteger statusCode, RARideDataModel *ride, NSError *error) {
                    weakSelf.backButton.enabled = YES;
                    if (error) {
                        [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
                        [UIView animateWithDuration:0.2 animations:^{
                            weakSelf.loadingContainer.alpha = 0.0;
                            [weakSelf updateRequestRideBtn];
                        }];
                        weakSelf.isRequestingDirectConnect = NO;
                    } else {
                        [UIView animateWithDuration:0.2 animations:^{
                            [weakSelf.btnRequestRide setEnabled:YES];
                        }];
                    }
                }];
                
            }];
        }];
    };
}

#pragma mark - CategoryChooserDelegate

- (void)didChooseCategoryWithName:(NSString *)categoryName {
    [self.driverDetailViewModel setSelectedCategory:categoryName];
    [self setupDesign];
}

#pragma mark - Segue Configuration

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue_DCDriverDetailViewController_CategoryChooserViewController"]) {
        CategoryChooserViewController *categoryChooserViewController = (CategoryChooserViewController *)segue.destinationViewController;
        categoryChooserViewController.carCategories = self.driverDirectConnectDataModel.categories;
        categoryChooserViewController.factors = self.driverDirectConnectDataModel.factors;
        categoryChooserViewController.categorySelected = self.driverDetailViewModel.category;
        categoryChooserViewController.delegate = self;
    }
}

@end
