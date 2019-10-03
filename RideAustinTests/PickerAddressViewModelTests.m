//
//  PickerAddressViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 09/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PickerAddressViewModel.h"

@interface PickerAddressViewModelTests : XCTestCase

@end

@implementation PickerAddressViewModelTests

- (void)testPropertiesForPickerTypeField {
    
    PickerAddressViewModel *viewModel = [[PickerAddressViewModel alloc] initWithPickerAddressFieldType: RAPickerAddressPickupFieldType isAddressSelected: YES];
    XCTAssertTrue([viewModel.title isEqualToString:@"Choose Pickup"]);
    XCTAssertTrue([viewModel.txtAddressPlaceholder isEqualToString:@"Enter Pickup"]);
    XCTAssertTrue([viewModel.addressNameIcon isEqualToString:@"circle-green-icon"]);
    XCTAssertTrue(viewModel.recentPlaceViewModels.count > 0);

}

- (void)testPropertiesForDestinationTypeField {
    
    PickerAddressViewModel *viewModel = [[PickerAddressViewModel alloc] initWithPickerAddressFieldType: RAPickerAddressDestinationFieldType isAddressSelected: YES];
    XCTAssertTrue([viewModel.title isEqualToString:@"Choose Destination"]);
    XCTAssertTrue([viewModel.txtAddressPlaceholder isEqualToString:@"Enter Destination"]);
    XCTAssertTrue([viewModel.addressNameIcon isEqualToString:@"circle-red-icon"]);
    XCTAssertTrue(viewModel.recentPlaceViewModels.count > 0);
    
}

@end
