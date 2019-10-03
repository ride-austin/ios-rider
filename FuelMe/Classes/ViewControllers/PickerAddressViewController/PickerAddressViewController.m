//
//  PickerAddressViewController.m
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressViewController.h"

#import "LocationService.h"
#import "PickerAddressSearchTextField.h"
#import "PickerAddressTableViewCell.h"
#import "PlaceMapChooserViewModel.h"
#import "RAAddress.h"
#import "RAFavoritePlacesManager.h"
#import "RARecentPlacesManager.h"
#import "SelectPlaceMapViewController.h"

#import <KVOController/NSObject+FBKVOController.h>

@interface PickerAddressViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *addressFieldIcon;
@property (weak, nonatomic) IBOutlet PickerAddressSearchTextField *txtAddress;
@property (weak, nonatomic) GMSMapView *googleMapView;

@property (strong, nonatomic) PickerAddressViewModel *pickerAddressViewModel;
@property (strong, nonatomic) NSArray<NSArray*> *placeDataSource;
@property (strong, nonatomic) NSString *previousAddress;

@end

@implementation PickerAddressViewController

#pragma mark - Lifecycle

- (instancetype)initWithDelegate:(id<PickerAddressDelegate>)delegate addressFieldType:(RAPickerAddressFieldType)pickerAddressFieldType previousAddress:(NSString *)previousAddress andMapView:(GMSMapView *)mapView {
    if (self = [super init]) {
        _delegate = delegate;
        BOOL isAddressSelected = previousAddress != nil && [previousAddress length] > 0;
        _pickerAddressViewModel = [[PickerAddressViewModel alloc] initWithPickerAddressFieldType:pickerAddressFieldType isAddressSelected:isAddressSelected];
        _previousAddress = previousAddress;
        self.googleMapView = mapView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self loadDefaultPlaceDataSource];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.pickerAddressViewModel.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.txtAddress becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.txtAddress.isFirstResponder) {
        [self.txtAddress resignFirstResponder];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.txtAddress.placeholder = self.pickerAddressViewModel.txtAddressPlaceholder;
    self.addressFieldIcon.image = [UIImage imageNamed:self.pickerAddressViewModel.addressNameIcon];
    
    [self configureTableView];
    [self configureAddressTextField];
}

- (void)configureAddressTextField {
    self.txtAddress.mapview = self.googleMapView;
    self.txtAddress.maximumNumberOfAutoCompleteRows = 10;
    self.txtAddress.delegate = self;
    self.txtAddress.text = self.previousAddress;
    self.txtAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
#ifdef AUTOMATION
    self.txtAddress.autocorrectionType = UITextAutocorrectionTypeNo;
#endif
}

- (void)configureTableView {
    self.tblPlaces.accessibilityIdentifier = @"tblAddressResult";
    self.tblPlaces.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tblPlaces registerClass:PickerAddressTableViewCell.class forCellReuseIdentifier:PickerAddressTableViewCell.className];
}

#pragma mark - Observers

- (void)addObservers {
    __weak PickerAddressViewController *weakSelf = self;
    [self.KVOController observe:self.txtAddress keyPath:@"placeViewModelsSuggestions" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        if (weakSelf.txtAddress.text.length > 0) {
            weakSelf.placeDataSource = @[weakSelf.txtAddress.placeViewModelsSuggestions];
            [weakSelf.tblPlaces reloadData];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        CGSize keyboardSize = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        weakSelf.tblPlaces.contentInset = insets;
        weakSelf.tblPlaces.scrollIndicatorInsets = insets;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        weakSelf.tblPlaces.contentInset = UIEdgeInsetsZero;
        weakSelf.tblPlaces.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        UITextField *textField = (UITextField *)note.object;
        if (textField == weakSelf.txtAddress && textField.text.length == 0) {
            [weakSelf loadDefaultPlaceDataSource];
        }
    }];
}

#pragma mark - ReadOnly Properties

- (RAPickerAddressFieldType)pickerAddressFieldType {
    return self.pickerAddressViewModel.pickerAddressFieldType;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableView Places DataSource

- (void)loadDefaultPlaceDataSource {
    self.placeDataSource = [self.pickerAddressViewModel recentPlaceViewModels];
    [self.tblPlaces reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.placeDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placeDataSource[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PickerAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PickerAddressTableViewCell.className];
    PlaceViewModel *vm = self.placeDataSource[indexPath.section][indexPath.row];
    cell.titleLabel.text = vm.title;
    cell.subtitleLabel.text = vm.subtitle;
    cell.iconImageView.image = vm.icon;
    cell.accessibilityLabel = vm.title;
    return cell;
}

#pragma mark - UITableView places Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlaceViewModel *placeViewModel = self.placeDataSource[indexPath.section][indexPath.row];
    switch (placeViewModel.type) {
        case PlaceViewModelAddHomeType:
        case PlaceViewModelAddWorkType:
        case PlaceViewModelSetLocationOnMapType:
            [self showMapChooserForPlaceViewModel:placeViewModel];
            break;
        case PlaceViewModelPlaceType:
            [self placeViewModelSelected:placeViewModel];
            break;
        case PlaceViewModelRemoveDestination:
            [self.delegate didRemoveDestinationFromPickerAddressViewController:self];
            break;
    }
}

#pragma mark - Handle Places

- (void)showMapChooserForPlaceViewModel:(PlaceViewModel *)placeViewModel {
    __weak PickerAddressViewController *weakSelf = self;
    
    self.title = @"";
    
    PlaceMapChooserViewModel *placeMapChooserViewModel = [[PlaceMapChooserViewModel alloc] initWithPlaceViewModel:placeViewModel pickerType:self.pickerAddressFieldType];
    
    SelectPlaceMapViewController *selectPlaceMapViewController = [[SelectPlaceMapViewController alloc] init];
    selectPlaceMapViewController.title = placeMapChooserViewModel.mapChooserTitle;
    selectPlaceMapViewController.descriptionTitle = placeMapChooserViewModel.mapChooserDescriptionTitle;
    selectPlaceMapViewController.icon = [UIImage imageNamed:placeMapChooserViewModel.mapChooserAddressFieldIconName];
    selectPlaceMapViewController.iconFrame = placeMapChooserViewModel.mapChooserFieldIconFrame;
    selectPlaceMapViewController.pinIcon = [UIImage imageNamed:placeMapChooserViewModel.mapChooserPinIconName];
    selectPlaceMapViewController.selectedPlaceBlock = ^(RAAddress *address) {
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        
        RAFavoritePlace *favoritePlace = [placeMapChooserViewModel favoritePlace];
        if (favoritePlace) {
            favoritePlace.coordinate    = address.location.coordinate;
            favoritePlace.shortAddress  = address.address;
            favoritePlace.fullAddress   = address.fullAddress;
            favoritePlace.zipCode       = address.zipCode;
            [RAFavoritePlacesManager saveFavoritePlace:favoritePlace];
        }
        
        RAPlace *place = [[RAPlace alloc] init];
        place.shortAddress = address.address;
        place.fullAddress = address.fullAddress;
        place.visibleAddress = favoritePlace.name ?: address.address;
        place.coordinate = address.location.coordinate;
        place.zipCode = address.zipCode;
        [weakSelf.delegate pickerAddressViewController:weakSelf didSelectPlace:place];
    };
   
    [self.navigationController pushViewController:selectPlaceMapViewController animated:YES];
}

- (void)placeViewModelSelected:(PlaceViewModel *)placeViewModel {
    if (!self.delegate) {
        return;
    }
    
    if (placeViewModel.reference) {
        __weak PickerAddressViewController *weakSelf = self;
        [[GMSPlacesClient sharedClient] lookUpPlaceID:placeViewModel.reference callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
            if (!error) {
                placeViewModel.coordinate = result.coordinate;
                for (GMSAddressComponent *addressComponent in result.addressComponents) {
                    if ([addressComponent.type isEqualToString:@"postal_code"]) {
                        placeViewModel.zipCode = addressComponent.name;
                    }
                }
                
                //Austin Airport should always show 3600 Presidential Blvd
                if ([[RADestination austinAirport] didMatchGoogleId:result.placeID]) {
                    placeViewModel.coordinate = CLLocationCoordinate2DMake(30.2021489, -97.666829);
                }
                
                placeViewModel.subtitle = result.formattedAddress;
                [weakSelf addRecentPlace:placeViewModel];
                [weakSelf.delegate pickerAddressViewController:weakSelf didSelectPlace:[placeViewModel place]];
            }
        }];
    } else {
        [self.delegate pickerAddressViewController:self didSelectPlace:[placeViewModel place]];
    }
}

- (void)addRecentPlace:(PlaceViewModel *)placeViewModel {
    RARecentPlace *recentPlace = [RARecentPlace new];
    recentPlace.name           = placeViewModel.title;
    recentPlace.shortAddress   = placeViewModel.title;
    recentPlace.fullAddress    = placeViewModel.subtitle;
    recentPlace.coordinate     = placeViewModel.coordinate;
    recentPlace.zipCode        = placeViewModel.zipCode;
    [RARecentPlacesManager addRecentPlace:recentPlace];
}

@end
