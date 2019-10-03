//
//  PickerAddressSearchTextField.h
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "MVPlaceSearchTextField.h"
#import "PlaceViewModel.h"

@interface PickerAddressSearchTextField : MVPlaceSearchTextField

@property (nonatomic) NSArray<PlaceViewModel *> *placeViewModelsSuggestions;

@end
