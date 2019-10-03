//
//  PlaceMapChooserViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 9/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PlaceMapChooserViewModel.h"

#import "RAHomeFavoritePlace.h"
#import "RAWorkFavoritePlace.h"
#import "NSString+Utils.h"

@interface PlaceMapChooserViewModel ()

@property (strong, nonatomic) PlaceViewModel *placeViewModel;
@property (assign, nonatomic) RAPickerAddressFieldType pickerType;

@end

@implementation PlaceMapChooserViewModel

- (instancetype)initWithPlaceViewModel:(PlaceViewModel *)placeViewModel pickerType:(RAPickerAddressFieldType)pickerType {
    if (self = [super init]) {
        _placeViewModel = placeViewModel;
        _pickerType = pickerType;
    }
    return self;
}

- (NSString *)mapChooserTitle {
    switch (self.placeViewModel.type) {
        case PlaceViewModelAddHomeType:
            return [@"Home" localized];
        case PlaceViewModelAddWorkType:
            return [@"Work" localized];
        case PlaceViewModelSetLocationOnMapType:{
            switch (self.pickerType) {
                case RAPickerAddressPickupFieldType:
                    return [@"Choose Pickup" localized];
                case RAPickerAddressDestinationFieldType:
                    return [@"Choose Destination" localized];
            }
        }
        default:
            return @"";
    }
}

- (NSString *)mapChooserDescriptionTitle {
    switch (self.placeViewModel.type) {
        case PlaceViewModelAddHomeType:
            return [@"Home" localized];
        case PlaceViewModelAddWorkType:
            return [@"Work" localized];
        case PlaceViewModelSetLocationOnMapType:{
            switch (self.pickerType) {
                case RAPickerAddressPickupFieldType:
                    return [@"Pickup" localized];
                case RAPickerAddressDestinationFieldType:
                    return [@"Destination" localized];
            }
        }
        default:
            return @"";
    }
}

- (NSString *)mapChooserAddressFieldIconName {
    switch (self.placeViewModel.type) {
        case PlaceViewModelAddHomeType:
            return @"addressHomeBlack";
        case PlaceViewModelAddWorkType:
            return @"addressWorkBlack";
        case PlaceViewModelSetLocationOnMapType:{
            switch (self.pickerType) {
                case RAPickerAddressPickupFieldType:
                    return @"circle-green-icon";
                case RAPickerAddressDestinationFieldType:
                    return @"circle-red-icon";
            }
        }
        default:
            return @"";
    }
}

- (NSString *)mapChooserPinIconName {
    switch (self.pickerType) {
        case RAPickerAddressPickupFieldType:
            return @"setupPin";
        case RAPickerAddressDestinationFieldType:
            return @"setup-pin-red";
    }
}

- (CGRect)mapChooserFieldIconFrame {
    switch (self.placeViewModel.type) {
        case PlaceViewModelAddWorkType:
        case PlaceViewModelAddHomeType:
            return CGRectMake(10, 10, 20, 20);
        case PlaceViewModelSetLocationOnMapType:
            return CGRectMake(15, 15, 10, 10);
        default:
            return CGRectZero;
    }
}

- (RAFavoritePlace *)favoritePlace {
    switch (self.placeViewModel.type) {
        case PlaceViewModelAddHomeType:
            return [RAHomeFavoritePlace new];
        case PlaceViewModelAddWorkType:
            return [RAWorkFavoritePlace new];
        default:
            return nil;
    }
}

@end
