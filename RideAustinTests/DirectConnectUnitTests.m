//
//  DirectConnectUnitTests.m
//  RideAustinTests
//
//  Created by Theodore Gonzalez on 12/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigGlobal.h"
#import "DCDriverDetailViewModel.h"
#import "NSDictionary+JSON.h"
#import "RARiderDataModel.h"

@interface DirectConnectUnitTests : XCTestCase

@property (nonatomic) ConfigGlobal *global;
@property (nonatomic) RARiderDataModel *rider;
@property (nonatomic) DCDriverDetailViewModel *viewModel;

@end

@implementation DirectConnectUnitTests

- (void)setUp {
    [super setUp];
    
    NSError *error = nil;
    id jsonConfig = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal"];
    id jsonRider  = [NSDictionary jsonFromResourceName:@"CURRENT_RIDER_200"];
    id jsonDriver = [NSDictionary jsonFromResourceName:@"DIRECT_CONNECT_DRIVER"];
    self.global = [MTLJSONAdapter modelOfClass:ConfigGlobal.class fromJSONDictionary:jsonConfig error:&error];
    XCTAssertNil(error);
    self.rider = [MTLJSONAdapter modelOfClass:RARiderDataModel.class fromJSONDictionary:jsonRider error:&error];
    XCTAssertNil(error);
    
    RADriverDirectConnectDataModel *model = [MTLJSONAdapter modelOfClass:RADriverDirectConnectDataModel.class fromJSONDictionary:jsonDriver error:&error];
    XCTAssertNil(error);
    
    self.viewModel = [[DCDriverDetailViewModel alloc] initWithDriverDirectConnect:model];
}

- (void)tearDown {
    [super tearDown];
}

//  24.2 Driver details

//  Direct Connect: Display driver photo
//  https://testrail.devfactory.com/index.php?/cases/view/2278123
- (void)testDisplayDriverPhoto_2278123 {
    XCTAssertTrue([self.viewModel.driverPhotoUrl isKindOfClass:NSURL.class]);
    XCTAssertEqualObjects(self.viewModel.driverPhotoUrl.absoluteString, @"http://media-stage.rideaustin.com/user-photos/91be7cb1-c815-4ca4-b68a-4bfcc1cf9274.png");
}

//  Direct Connect: Display driver name
//  https://testrail.devfactory.com/index.php?/cases/view/2278124
- (void)testDisplayDriverName_2278124 {
    XCTAssertEqualObjects(self.viewModel.driverFullName, @"driver first name driver last name");
}

//  Direct Connect: Display driver rating
//  https://testrail.devfactory.com/index.php?/cases/view/2278125
- (void)testDisplayDriverRating_2278125 {
    XCTAssertEqualObjects(self.viewModel.driverRating, @"4.12");
}

//  Direct Connect: Display the cheapest car category as default
//  https://testrail.devfactory.com/index.php?/cases/view/2278126
- (void)testDisplayCheapestCarCategory_2278126 {
    XCTAssertEqualObjects(self.viewModel.selectedCategory, @"SUV");
}

//  Direct Connect: Display the surge factor for car category if available
//  https://testrail.devfactory.com/index.php?/cases/view/2278127
- (void)testDisplaySurgeFactor_2278127 {
    XCTAssertEqualObjects(self.viewModel.priority, @"1.00");
    self.viewModel.selectedCategory = @"REGULAR";
    XCTAssertEqualObjects(self.viewModel.priority, @"4.10");
}

@end
