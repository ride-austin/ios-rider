//
//  RAEstimatedFareViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 15/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RAEstimatedFareViewModel.h"
#import "RAEstimate.h"
#import "NSDictionary+JSON.h"

@interface RAEstimatedFareViewModelTests : XCTestCase

@property (nonatomic) RAEstimatedFareViewModel *viewModel;

@end

@implementation RAEstimatedFareViewModelTests

- (void)setUp {
    
    id jsonEstimate = [NSDictionary jsonFromResourceName:@"ESTIMATE_MOCK"];
    RAEstimate * estimate = [MTLJSONAdapter modelOfClass:RAEstimate.class fromJSONDictionary:jsonEstimate error: nil];
    self.viewModel = [[RAEstimatedFareViewModel alloc] initWithStartAddress:@"Start" endAddress:@"End" estimate:estimate];
}


-(void) testViewModel {
    XCTAssertNotNil(self.viewModel);
}

-(void) testDisplayFareEstimate {
    XCTAssertTrue([[self.viewModel displayFareEstimate] isEqualToString:@"$ 10.0"]);
}

-(void) testTitle {
    XCTAssertTrue([[self.viewModel title] isEqualToString:@"Fare Estimate"]);
}

-(void) testStartAddress {
    XCTAssertTrue([[self.viewModel startAddress] isEqualToString:@"Start"]);
}

-(void) testEndAddress {
    XCTAssertTrue([[self.viewModel endAddress] isEqualToString:@"End"]);
}

@end
