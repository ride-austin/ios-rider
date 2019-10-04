#import "AssetCityManager.h"
#import "ConfigRegistration.h"
#import "DriverSignUpViewController.h"
#import "NSString+Utils.h"
#import "RACityAPI.h"
#import "RACityDropDown.h"
#import "RADriverAPI.h"
#import "Ride-Swift.h"
#import "UIColor+HexUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DriverSignUpViewController () <RACityDropDownDelegate>

//IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *slogan;
@property (weak, nonatomic) IBOutlet UIImageView *logoRide;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIAlertController *alert;
@property (nonatomic, strong) UIViewController *rootController;
@property (strong, nonatomic) NSMutableDictionary *userData;
@property (strong, nonatomic) RACityDropDown *dropDown;
@property (strong, nonatomic) RACity *selectedCity;
@property (strong, nonatomic) NSArray<RACity*> *cities;

@end

@implementation DriverSignUpViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureData];
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    __weak DriverSignUpViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self
                                           statusChangedBlock:^(RANetworkReachability networkReachability) {
                                               if (networkReachability == RANetworkReachable) {
                                                   [weakSelf updateDataWithCity:weakSelf.selectedCity];
                                               }
                                               else{
                                                   weakSelf.registerButton.enabled = NO;
                                                   [weakSelf.alert dismissViewControllerAnimated:YES completion:nil];
                                               }
                                           }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.registerButton.layer.cornerRadius = self.registerButton.frame.size.height/2;
    self.cancelButton.layer.cornerRadius   = self.cancelButton.frame.size.height/2;
}

- (void)updateConfigCity:(RACity *)city andDetail:(RACityDetail *)detail {
    [self.coordinator updateWithCity:city detail:detail];
    self.registerButton.enabled = city != nil && detail != nil;
}

- (ConfigRegistration *)regConfig {
    return self.coordinator.regConfig;
}

#pragma mark - Actions

- (IBAction)registerButtonPressed:(UIButton *)sender {
    
    //RA-2909
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self cancelButtonPressed:nil];
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showStartOfRegistration];
    }];
    
    self.alert = [UIAlertController alertControllerWithTitle:self.selectedCity.appName
                                                     message:[@"Have you had your license for at least ONE year?" localized]
                                              preferredStyle:UIAlertControllerStyleAlert];
    [self.alert addAction:noAction];
    [self.alert addAction:yesAction];
    
    [self presentViewController:self.alert animated:YES completion:nil];
}

- (void)showStartOfRegistration {
    if(!self.userData){
        self.userData = [NSMutableDictionary dictionary];
    }
    
    [self showNext];
}

- (void)showNext {
    [RADriverAPI getDriverTermsAtURL:self.regConfig.cityDetail.driverRegistrationTermsURL withCompletion:^(NSString * _Nullable terms, NSError * _Nullable error) {
        if (!error) {
            self.regConfig.driverTerms = terms;
        }
    }];
    
    [self.coordinator showNextScreenFromScreen:DSScreenCitySelection];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.coordinator endDriverSignup];
}

- (IBAction)selectClicked:(id)sender {
    //avoid any crashes if not data yet
    if (self.cities.count == 0) {
        return;
    }
    
    if(self.dropDown == nil) {
        CGFloat f = 90;
        self.dropDown = [[RACityDropDown alloc] showDropDown:sender height:f options:self.cities direction:@"down"];
        self.dropDown.delegate = self;
    } else {
        [self.dropDown hideDropDown:sender];
        [self rel];
    }
}

#pragma mark - RACityDropDownDelegate

- (void) RACityDropDownDidSelect:(RACity *)selected {
    [self rel];
    [self updateUIWithCity:selected];
    [self updateDataWithCity:selected];
}

- (void)rel {
    [self.dropDown removeFromSuperview];
    self.dropDown = nil;
    [self.btnSelect setNeedsLayout];
    [self.btnSelect layoutIfNeeded];
}

#pragma mark - Load Data

- (void)configureData {
    self.cities = [NSArray arrayWithArray:[ConfigurationManager shared].global.supportedCities];
    [self configureDefault];
}

- (void)configureDefault {
    self.selectedCity = [ConfigurationManager shared].global.currentCity;
    [self updateUIWithCity:self.selectedCity];
    [self updateDataWithCity:self.selectedCity];
}

#pragma mark - Configure Helpers

- (void)configureUI {
    self.registerButton.enabled = NO;
    self.registerButton.backgroundColor = [UIColor colorWithHex:@"#1DA9F6"];
    self.cancelButton.layer.borderColor = [UIColor colorWithHex:@"#1DA9F6"].CGColor;
    self.cancelButton.layer.borderWidth = 1.5;
    
    if (self.rootController) {
        self.slogan.text = [@"Sign Up to Drive" localized];
        [self.registerButton setTitle:[@"CONTINUE" localized] forState:UIControlStateNormal];
        [self.cancelButton setTitle:[@"CANCEL" localized] forState:UIControlStateNormal];
    }
}

- (void)updateDataWithCity:(RACity *)city {
    [self.activityIndicator startAnimating];
    self.registerButton.enabled = NO;
    [RACityAPI getCityDetailWithId:city.cityID withCompletion:^(RACityDetail *cityDetail, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            [self updateUIWithCity:self.selectedCity];
        } else {
            self.selectedCity = city;
            [self updateConfigCity:city andDetail:cityDetail];
        }
    }];
}

- (void)updateUIWithCity:(RACity *)city {
    //update selected label
    self.selectLabel.text = city.displayName;
    
    //update image logo
    [self.logoRide sd_setImageWithURL:city.logoBlackURL
                     placeholderImage:[AssetCityManager logoImageByCityType:city.cityType]];
    self.title = [NSString stringWithFormat:[@"Drive with %@" localized], city.appName];
}

@end
