//
//  PlaceViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 09/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PlaceViewModel.h"

@interface PlaceViewModelTests : XCTestCase
@end

@implementation PlaceViewModelTests


- (void)testPlaceViewModel {
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeHome reference:@"testref" type:PlaceViewModelAddHomeType];
    viewModel.coordinate = CLLocationCoordinate2DMake(30.232, -72.4234);
    RAPlace * place = [viewModel place];
    XCTAssertNotNil(viewModel);
    XCTAssertNotNil(place);
    XCTAssertTrue([place.shortAddress isEqualToString:@"TestTitle"]);
    XCTAssertTrue([place.fullAddress isEqualToString:@"Subtitle"]);
    XCTAssertTrue(place.coordinate.latitude == 30.232);
    XCTAssertTrue(place.coordinate.longitude == -72.4234);
   
}

- (void)testPlaceViewModelWithFavouritePlace {
    
    RAFavoritePlace * favourite = [[RAFavoritePlace alloc] init];
    favourite.name = @"TestTitle";
    favourite.shortAddress = @"ShortAddress";
    favourite.grayIconName = @"address-home-icon";
    favourite.coordinate = CLLocationCoordinate2DMake(30.232, -72.4234);
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithFavoritePlace:favourite];
    RAPlace * place = [viewModel place];
    XCTAssertNotNil(viewModel);
    XCTAssertNotNil(place);
    XCTAssertTrue([place.shortAddress isEqualToString:@"ShortAddress"]);
    XCTAssertTrue([place.fullAddress isEqualToString:@"ShortAddress"]);
    XCTAssertTrue(place.coordinate.latitude == 30.232);
    XCTAssertTrue(place.coordinate.longitude == -72.4234);
    XCTAssertTrue(viewModel.iconType == PlaceIconTypeHome);
    
    
    
}

- (BOOL) compareFirstImages: (UIImage*) firstImage withSecondImage: (UIImage*) secondImage {
    NSData *data1 = UIImagePNGRepresentation(firstImage);
    NSData *data2 = UIImagePNGRepresentation(secondImage);
    
    return [data1 isEqual:data2];
}


- (void) testAddHomePlaceIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeHome reference:@"testref" type:PlaceViewModelAddHomeType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-home-icon"]]);
}



- (void) testAddWorkPlaceIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeWork reference:@"testref" type:PlaceViewModelAddWorkType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-work-icon"]]);
}

- (void) testSelectOnMapIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeSelectOnMap reference:@"testref" type:PlaceViewModelAddWorkType];
     XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-location-on-map-icon"]]);
}

- (void) testHistoryIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeHistory reference:@"testref" type:PlaceViewModelAddWorkType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-history-icon"]]);
}

- (void) testTransitIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeTransit reference:@"testref" type:PlaceViewModelAddWorkType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"transit_icon"]]);
}

- (void) testRemoveDestinationIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeRemoveDestination reference:@"testref" type:PlaceViewModelAddWorkType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-remove-destination-icon"]]);
}

- (void) testDefaultIcon {
    
    PlaceViewModel * viewModel = [[PlaceViewModel alloc] initWithTitle:@"TestTitle" subtitle:@"Subtitle" iconType: PlaceIconTypeDefault reference:@"testref" type:PlaceViewModelAddWorkType];
    XCTAssertTrue([self compareFirstImages:[viewModel icon] withSecondImage:[UIImage imageNamed:@"address-place-icon"]]);
}


@end
