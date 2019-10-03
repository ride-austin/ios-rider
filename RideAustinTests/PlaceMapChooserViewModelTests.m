//
//  PlaceMapChooserViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 10/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PlaceMapChooserViewModel.h"


@interface PlaceMapChooserViewModelTests : XCTestCase

@end

@implementation PlaceMapChooserViewModelTests

- (void)testPlaceMapChooserViewModeHomeType {
    PlaceViewModel * placeViewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeHome reference:@"testref" type:PlaceViewModelAddHomeType];
    PlaceMapChooserViewModel * viewModel = [[PlaceMapChooserViewModel alloc] initWithPlaceViewModel:placeViewModel pickerType:RAPickerAddressPickupFieldType];

    XCTAssertNotNil(viewModel);
    XCTAssertTrue([viewModel.mapChooserTitle isEqualToString:@"Home"]);
    XCTAssertTrue([viewModel.mapChooserDescriptionTitle isEqualToString:@"Home"]);
    XCTAssertTrue([viewModel.mapChooserAddressFieldIconName isEqualToString:@"addressHomeBlack"]);
    XCTAssertTrue([viewModel.mapChooserPinIconName isEqualToString:@"setupPin"]);
}

- (void)testPlaceMapChooserViewModeWorkType {
    PlaceViewModel * placeViewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeWork reference:@"testref" type:PlaceViewModelAddWorkType];
    PlaceMapChooserViewModel * viewModel = [[PlaceMapChooserViewModel alloc] initWithPlaceViewModel:placeViewModel pickerType:RAPickerAddressDestinationFieldType];
    
    XCTAssertNotNil(viewModel);
    XCTAssertTrue([viewModel.mapChooserTitle isEqualToString:@"Work"]);
    XCTAssertTrue([viewModel.mapChooserDescriptionTitle isEqualToString:@"Work"]);
    XCTAssertTrue([viewModel.mapChooserAddressFieldIconName isEqualToString:@"addressWorkBlack"]);
    XCTAssertTrue([viewModel.mapChooserPinIconName isEqualToString:@"setup-pin-red"]);
}

- (void)testPlaceMapChooserViewModeSelectOnMapDestination {
    PlaceViewModel * placeViewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeWork reference:@"testref" type:PlaceViewModelSetLocationOnMapType];
    PlaceMapChooserViewModel * viewModel = [[PlaceMapChooserViewModel alloc] initWithPlaceViewModel:placeViewModel pickerType:RAPickerAddressDestinationFieldType];
    
    XCTAssertNotNil(viewModel);
    XCTAssertTrue([viewModel.mapChooserTitle isEqualToString:@"Choose Destination"]);
    XCTAssertTrue([viewModel.mapChooserDescriptionTitle isEqualToString:@"Destination"]);
    XCTAssertTrue([viewModel.mapChooserAddressFieldIconName isEqualToString:@"circle-red-icon"]);
    XCTAssertTrue([viewModel.mapChooserPinIconName isEqualToString:@"setup-pin-red"]);
}

- (void)testPlaceMapChooserViewModeSelectOnMapPickup {
    PlaceViewModel * placeViewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeWork reference:@"testref" type:PlaceViewModelSetLocationOnMapType];
    PlaceMapChooserViewModel * viewModel = [[PlaceMapChooserViewModel alloc] initWithPlaceViewModel:placeViewModel pickerType:RAPickerAddressPickupFieldType];
    
    XCTAssertNotNil(viewModel);
    XCTAssertTrue([viewModel.mapChooserTitle isEqualToString:@"Choose Pickup"]);
    XCTAssertTrue([viewModel.mapChooserDescriptionTitle isEqualToString:@"Pickup"]);
    XCTAssertTrue([viewModel.mapChooserAddressFieldIconName isEqualToString:@"circle-green-icon"]);
    XCTAssertTrue([viewModel.mapChooserPinIconName isEqualToString:@"setupPin"]);
}

@end
