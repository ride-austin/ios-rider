//
//  CostViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 12/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CostViewModel.h"

@interface CostViewModelTests : XCTestCase

@end

@implementation CostViewModelTests

-(void) testCostViewModelWithRate {
    
    CostViewModel * viewModel = [CostViewModel modelWithTitle:@"title" andRate:[NSNumber numberWithInt:10]];
    
    XCTAssertTrue([[viewModel displayValue] isEqualToString:@"10%"]);
}

-(void) testCostViewModelWithAmount {
    
    CostViewModel * viewModel = [CostViewModel modelWithTitle:@"title" andAmount:12.23];
    
    XCTAssertTrue([[viewModel displayValue] isEqualToString:@"$ 12.23"]);
}

-(void) testCostViewModelWithFeeTypeAmount {
    
    NSDictionary *feeDict = @{
                              @"title" : @"testTitle",
                              @"value" : @10,
                              @"valueType" : @"amount",
                              @"description" : @"test description"
                              };
    RAFee * fee = [MTLJSONAdapter modelOfClass:RAFee.class fromJSONDictionary:feeDict error:nil];
    CostViewModel * viewModel = [CostViewModel modelWithFee:fee];
    
    XCTAssertTrue([[viewModel displayValue] isEqualToString:@"$ 10.00"]);
}

-(void) testCostViewModelWithFeeTypeRate {
    
    NSDictionary *feeDict = @{
                              @"title" : @"testTitle",
                              @"value" : @10,
                              @"valueType" : @"rate",
                              @"description" : @"test description"
                              };
    RAFee * fee = [MTLJSONAdapter modelOfClass:RAFee.class fromJSONDictionary:feeDict error:nil];
    CostViewModel * viewModel = [CostViewModel modelWithFee:fee];
    
    XCTAssertTrue([[viewModel displayValue] isEqualToString:@"10%"]);
}
@end
