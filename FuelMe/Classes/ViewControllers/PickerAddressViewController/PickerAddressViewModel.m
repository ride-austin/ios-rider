//
//  PickerAddressViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressViewModel.h"

#import "NSString+Utils.h"
#import "PlaceViewModel.h"
#import "RAFavoritePlacesManager.h"
#import "RARecentPlacesManager.h"
#import "RARideManager.h"

@interface PickerAddressViewModel ()

@property (assign, nonatomic, readwrite) RAPickerAddressFieldType pickerAddressFieldType;
@property (assign, nonatomic) BOOL isAddressSelected;

@end

@implementation PickerAddressViewModel

#pragma mark - Lifecycle

- (instancetype)initWithPickerAddressFieldType:(RAPickerAddressFieldType)pickerAddressFieldType isAddressSelected:(BOOL)isAddressSelected {
    if (self = [super init]) {
        _pickerAddressFieldType = pickerAddressFieldType;
        _isAddressSelected = isAddressSelected;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)title {
    switch (self.pickerAddressFieldType) {
        case RAPickerAddressPickupFieldType:      return [@"Choose Pickup" localized];
        case RAPickerAddressDestinationFieldType: return [@"Choose Destination" localized];
    }
}

- (NSString *)txtAddressPlaceholder {
    switch (self.pickerAddressFieldType) {
        case RAPickerAddressPickupFieldType:       return [@"Enter Pickup" localized];
        case RAPickerAddressDestinationFieldType:  return [@"Enter Destination" localized];
    }
}

- (NSString *)addressNameIcon {
    switch (self.pickerAddressFieldType) {
        case RAPickerAddressPickupFieldType:       return @"circle-green-icon";
        case RAPickerAddressDestinationFieldType:  return @"circle-red-icon";
    }
}

- (NSArray<PlaceViewModel *> *)recentPlaceViewModels {
    NSMutableArray *recentPlaceViewModelsResponse = [[NSMutableArray alloc] init];
    if ([self removeDestinationModelSection]) {
        [recentPlaceViewModelsResponse addObject:[self removeDestinationModelSection]];
    }
    [recentPlaceViewModelsResponse addObject:[self favoritePlaceViewModelSection]];
    [recentPlaceViewModelsResponse addObject:[self recentPlaceViewModelSection]];
    [recentPlaceViewModelsResponse addObject:[self setLocationOnMapSection]];
    return recentPlaceViewModelsResponse;
}

- (NSArray<PlaceViewModel *> *)removeDestinationModelSection {
    if (self.pickerAddressFieldType == RAPickerAddressDestinationFieldType && self.isAddressSelected && ![[RARideManager sharedManager] isRiding]) {
        return @[[[PlaceViewModel alloc] initWithTitle:@"Remove Destination".localized subtitle:nil iconType:PlaceIconTypeRemoveDestination reference:nil type:PlaceViewModelRemoveDestination]];
    }
    return nil;
}

- (NSArray<PlaceViewModel *> *)favoritePlaceViewModelSection {
    NSMutableArray<PlaceViewModel *> *favoritePlacesSection = [[NSMutableArray alloc] init];
    
    //Home
    RAHomeFavoritePlace *homePlace = [RAFavoritePlacesManager homePlace];
    PlaceViewModel *homePlaceViewModel = [[PlaceViewModel alloc] initWithFavoritePlace:homePlace];
    if (!homePlaceViewModel) {
        homePlaceViewModel = [[PlaceViewModel alloc] initWithTitle:@"Add Home".localized subtitle:nil iconType:PlaceIconTypeHome reference:nil type:PlaceViewModelAddHomeType];
    }
    [favoritePlacesSection addObject:homePlaceViewModel];
    
    //Work
    RAWorkFavoritePlace *workPlace = [RAFavoritePlacesManager workPlace];
    PlaceViewModel *workPlaceViewModel = [[PlaceViewModel alloc] initWithFavoritePlace:workPlace];
    if (!workPlaceViewModel) {
        workPlaceViewModel = [[PlaceViewModel alloc] initWithTitle:@"Add Work".localized subtitle:nil iconType:PlaceIconTypeWork reference:nil type:PlaceViewModelAddWorkType];
    }
    [favoritePlacesSection addObject:workPlaceViewModel];
    return favoritePlacesSection;
}

- (NSArray<PlaceViewModel *> *)setLocationOnMapSection {
    //Setup Location on Map
    PlaceViewModel *setLocationOnMap = [[PlaceViewModel alloc] initWithTitle:@"Set Location On Map".localized subtitle:nil iconType:PlaceIconTypeSelectOnMap reference:nil type:PlaceViewModelSetLocationOnMapType];
    return @[setLocationOnMap];
}

- (NSArray<PlaceViewModel *> *)recentPlaceViewModelSection {
    NSMutableArray<PlaceViewModel *> *recentPlacesSection = [[NSMutableArray alloc] init];
    for (RARecentPlace *place in [RARecentPlacesManager recentPlaces]) {
        PlaceViewModel *vm = [[PlaceViewModel alloc] initWithTitle:place.shortAddress subtitle:place.fullAddress iconType:PlaceIconTypeHistory reference:nil type:PlaceViewModelPlaceType];
        vm.coordinate = place.coordinate;
        [recentPlacesSection addObject:vm];
    }
    return recentPlacesSection;
}

@end
