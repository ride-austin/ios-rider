//
//  CitySignupTests.m
//  Ride
//
//  Created by Carlos Alcala on 11/21/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigGlobal.h"
#import "RACityDropDown.h"
#import "UIColor+HexUtils.h"
#import "NSDictionary+JSON.h"
@interface CityUnitTests : XCTestCase

@property (strong, nonatomic) RACity *cityObject;
@property (strong, nonatomic) RACityDropDown *dropDown;
@property (strong, nonatomic) RACity *selectedCity;
@property (strong, nonatomic) NSArray<RACity*> *cities;

@end

@implementation CityUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self loadCityData];
    
}

- (void)loadCityData {
    NSError *error = nil;
    id response = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal" error:&error];
    ConfigGlobal *global = [MTLJSONAdapter modelOfClass:[ConfigGlobal class] fromJSONDictionary:response error:&error];
    
    self.cities = global.supportedCities;
    
    CGFloat f = 90;
    UIButton* sender = [[UIButton alloc] init];
    
    self.dropDown = [[RACityDropDown alloc] showDropDown:sender height:f options:self.cities direction:@"down"];
    
    self.cityObject = global.currentCity;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCityModelIsNotNil {
    XCTAssertNotNil(self.cityObject, @"City object init failed");
}

- (void)testCityModelProperties {
    XCTAssertTrue([self.cityObject containsCoordinate:CLLocationCoordinate2DMake(30.267153, -97.743061)]);
    XCTAssertTrue([self.cityObject.cityID isEqualToNumber:@(1)]);
    XCTAssertTrue([self.cityObject.name   isEqualToString:@"AUSTIN"]);
    XCTAssertTrue( self.cityObject.cityType == Austin);
}

- (void)testSelectedCity {
    XCTAssertEqual(self.cities.count, 2);
    //selected city for testing
    self.selectedCity = self.cities[1];
    XCTAssertNotNil(self.selectedCity, @"City object init failed");
    XCTAssertTrue([self.selectedCity.cityID isEqualToNumber:@(2)]);
    XCTAssertTrue([self.selectedCity.name   isEqualToString:@"HOUSTON"]);
    XCTAssertTrue([self.selectedCity.imageURL.absoluteString isEqualToString:@"https://media.rideaustin.com/images/logoRideHouston@3x.png"]);
}

#pragma mak - DropDown Test

- (void)testDropdownObject {
    XCTAssertNotNil(self.dropDown, @"DropDown object init failed");
}

- (void)testDropdown {
    XCTAssertEqual(self.dropDown.list.count, 2, @"DropDown list options failed load");
}

@end
