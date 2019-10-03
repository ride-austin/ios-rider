//
//  PlaceMapChooserViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 9/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressViewModel.h"
#import "PlaceViewModel.h"

@interface PlaceMapChooserViewModel : NSObject

@property (nonatomic, readonly) NSString *mapChooserTitle;
@property (nonatomic, readonly) NSString *mapChooserDescriptionTitle;
@property (nonatomic, readonly) NSString *mapChooserAddressFieldIconName;
@property (nonatomic, readonly) NSString *mapChooserPinIconName;
@property (nonatomic, readonly) CGRect mapChooserFieldIconFrame;

- (instancetype)initWithPlaceViewModel:(PlaceViewModel *)placeViewModel pickerType:(RAPickerAddressFieldType)pickerType;

- (RAFavoritePlace *)favoritePlace;

@end
