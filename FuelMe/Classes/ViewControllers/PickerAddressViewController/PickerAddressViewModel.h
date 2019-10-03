//
//  PickerAddressViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlaceViewModel.h"
#import "RideConstants.h"

@interface PickerAddressViewModel : NSObject

@property (assign, nonatomic, readonly) RAPickerAddressFieldType pickerAddressFieldType;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *txtAddressPlaceholder;
@property (nonatomic, readonly) NSString *addressNameIcon;
@property (nonatomic, readonly) NSArray  *recentPlaceViewModels;

- (instancetype)initWithPickerAddressFieldType:(RAPickerAddressFieldType)pickerAddressFieldType isAddressSelected:(BOOL)isAddressSelected;

@end
