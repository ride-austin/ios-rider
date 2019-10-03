//
//  SelectPlaceMapViewController.m
//  Ride
//
//  Created by Kitos on 20/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SelectPlaceMapViewController.h"

#import "GeocoderService.h"
#import "GoogleMapsManager.h"
#import "LocationService.h"
#import "NSString+Utils.h"
#import "RAAddress.h"
#import "RideAustinPlaceSearchTextField.h"

#import <GoogleMaps/GoogleMaps.h>
#import <KVOController/NSObject+FBKVOController.h>

static NSString *const kSelectedPlacePinIdentifier = @"kSelectedPlacePinIdentifier";
static NSString *const kMyLocationKeyPath = @"myLocation";

@interface SelectPlaceMapViewController ()<UITextFieldDelegate, PlaceSearchTextFieldDelegate, GMSMapViewDelegate>

//IBOutlets

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet RideAustinPlaceSearchTextField *placeTextField;

//Properties
@property (nonnull, strong) GoogleMapsManager *googleMapsManager;
@property (nonatomic) RAAddress *selectedAddress;
@property (nonatomic) BOOL mapWasMovedWithUserGesture;

//IBActions
- (IBAction)infoButtonPressed:(UIButton*)sender;
- (IBAction)myLocationButtonPressed:(UIButton*)sender;
- (void)saveButtonPressed:(UIButton*)sender;
- (void)enableSaveButton:(BOOL)enable;

@end

@implementation SelectPlaceMapViewController

#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAccessibility];
    [self configureNavigationBar];
    [self configureMap];
    [self configureObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureAccessibility {
    self.placeTextField.accessibilityLabel = [@"Your place." localized];
    self.placeTextField.accessibilityTraits = UIAccessibilityTraitSearchField;
}

- (void)configureNavigationBar {
    UIBarButtonItem *saveButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButon;
}

- (void)configureMap {
    self.googleMapsManager = [[GoogleMapsManager alloc] initWithMap:self.googleMapView];
    self.googleMapView.myLocationEnabled = YES;
    self.googleMapView.delegate = self;
    self.googleMapView.indoorEnabled = NO;
    self.googleMapView.accessibilityElementsHidden = YES;
    [self.googleMapsManager animateCameraToCoordinate:self.googleMapView.myLocation.coordinate zoom:kGMSMaxZoomLevel - 3];
    [self configureAddressField];
    [self configureInitialLocation];
    [self configurePin];
    
#ifdef  AUTOMATION
    self.googleMapView.accessibilityElementsHidden = NO;
#endif
}

- (void)configurePin {
    if (!self.pinIcon) {
        self.pinIcon = [UIImage imageNamed:@"setupPin"];
    }
    
    UIImageView *locationPin = [[UIImageView alloc] initWithImage:self.pinIcon];
    locationPin.translatesAutoresizingMaskIntoConstraints = NO;
    locationPin.contentMode = UIViewContentModeScaleAspectFit;
    locationPin.layer.anchorPoint = CGPointMake(0.5, 1.0);
    [self.view addSubview:locationPin];
    
    [NSLayoutConstraint activateConstraints:
     @[
       [locationPin.centerYAnchor constraintEqualToAnchor:self.view.compatibleCenterYAnchor],
       [locationPin.centerXAnchor constraintEqualToAnchor:self.view.compatibleCenterXAnchor],
       [locationPin.heightAnchor  constraintEqualToConstant:37]
       ]];
}

- (void)configureAddressField {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.iconFrame = CGRectIsNull(self.iconFrame) ? CGRectMake(10, 10, 20, 20) : self.iconFrame;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:self.iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.image = self.icon;
    [paddingView addSubview:iconView];
    self.placeTextField.leftView = paddingView;
    self.placeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.placeTextField.mapview = self.googleMapView;
    self.placeTextField.placeSearchDelegate = self;
    self.placeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)configureInitialLocation {
    if (self.initialLocation) {
        self.placeTextField.text = self.initialAddress;
        [self.googleMapsManager animateCameraToCoordinate:self.initialLocation.coordinate zoom:kGMSMaxZoomLevel - 3];
    } else {
        [self showHUD];
        __weak SelectPlaceMapViewController *weakSelf = self;
        [self getMyCurrentLocationWithCompletion:^(CLLocation *location, NSError *error) {
            [weakSelf hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
            } else {
                [weakSelf.googleMapsManager animateCameraToCoordinate:location.coordinate zoom:kGMSMaxZoomLevel - 3];
                [weakSelf updateUIWithCoordinate:location.coordinate];
            }
        }];
    }
}

#pragma mark - Helpers

- (void)getMyCurrentLocationWithCompletion:(LocationResult)completion {
    if (self.googleMapsManager) {
        CLLocation *locationFromMap = [self.googleMapsManager getMyCurrentLocation];
        if (locationFromMap) {
            completion(locationFromMap,nil);
            return;
        }
    }
    
    if ([LocationService sharedService].myLocation) {
        completion([LocationService sharedService].myLocation, nil);
        return;
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

- (void)configureObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - IBActions

- (void)infoButtonPressed:(UIButton *)sender {
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"OK" localized] style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:[@"Setting Your %@ Address" localized], self.descriptionTitle] message:[@"Enter your address, search the name of your location, or drop a pin on the map. Don’t forget to hit ‘Done’ when you are finished." localized] preferredStyle:UIAlertControllerStyleAlert];
    [infoAlert addAction:cancelAction];
    
    [self presentViewController:infoAlert animated:YES completion:nil];
}

- (void)myLocationButtonPressed:(UIButton *)sender {
    CLLocationCoordinate2D currentUserCoordinate = self.googleMapView.myLocation.coordinate;
    [self.googleMapsManager animateCameraToCoordinate:currentUserCoordinate zoom:self.googleMapView.camera.zoom];
    [self updateUIWithCoordinate:currentUserCoordinate];
}

- (void)saveButtonPressed:(UIButton *)sender {
    if (!self.selectedAddress) {
        [self enableSaveButton:NO];
        return;
    }
    
    //When a selectedPlaceBlock is passed the caller is responsible to
    //close controller.
    if (self.selectedPlaceBlock) {
        self.selectedPlaceBlock(self.selectedAddress);
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)enableSaveButton:(BOOL)enable {
    self.navigationItem.rightBarButtonItem.enabled = enable && [[RANetworkManager sharedManager] isNetworkReachable];
}

#pragma mark - Update UI

- (void)updateUIWithCoordinate:(CLLocationCoordinate2D)coordinate {
    __weak SelectPlaceMapViewController *weakSelf = self;
    [[GeocoderService sharedInstance] reverseGeocodeForCoordinate:coordinate completion:^(RAAddress * _Nullable address, NSError * _Nullable error) {
        if (!error) {
            weakSelf.selectedAddress = address;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.placeTextField.text = address.address;
                [weakSelf enableSaveButton:(error == nil)];
            });
        }
    }];
}

#pragma mark GoogleMaps Delegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.view endEditing:YES];
    [self dismissKeyboard];
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if (gesture) {
        [self enableSaveButton:NO];
        [self dismissKeyboard];
    }
    self.mapWasMovedWithUserGesture = gesture;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (self.mapWasMovedWithUserGesture) {
        [self enableSaveButton:NO];
        [self updateUIWithCoordinate:mapView.camera.target];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self enableSaveButton:NO];
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    BOOL didClear = textField == self.placeTextField && textField.text.length == 0;
    if (didClear) {
        [self enableSaveButton:NO];
    }
}

- (void)placeSearch:(MVPlaceSearchTextField *)textField ResponseForSelectedPlace:(GMSPlace *)responseDict {
    RAAddress *address = [[RAAddress alloc] init];
    address.address = responseDict.name;
    address.fullAddress = responseDict.formattedAddress;
    address.location = [[CLLocation alloc] initWithLatitude:responseDict.coordinate.latitude longitude:responseDict.coordinate.longitude];
    
    for (GMSAddressComponent *addressComponent in responseDict.addressComponents) {
        if ([addressComponent.type isEqualToString:@"postal_code"]) {
            address.zipCode = addressComponent.name;
        }
    }
    
    self.selectedAddress = address;
    self.placeTextField.text = address.address;
    [self.googleMapsManager animateCameraToCoordinate:address.location.coordinate];
    [self enableSaveButton:YES];
}

@end
