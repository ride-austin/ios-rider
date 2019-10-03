//
//  GenderViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 15/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GenderViewModel.h"
#import "ConfigGlobal.h"
#import "NSDictionary+JSON.h"

@interface GenderViewModelTests : XCTestCase
@property (nonatomic) GenderViewModel *viewModel;
@property (nonatomic) ConfigGlobal *globalConfig;

@end

@implementation GenderViewModelTests

- (void)setUp {
    
    NSError *error = nil;
    id response = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal" error:&error];
    self.globalConfig = [MTLJSONAdapter modelOfClass:[ConfigGlobal class] fromJSONDictionary:response error:&error];
    
    self.viewModel = [GenderViewModel viewModelWithConfig:self.globalConfig andDidSaveGenderHandler:^(RAUserDataModel * _Nonnull user) {
    }];
    
    XCTAssert(error == nil);
}

- (void)testViewModelNotNil {
    XCTAssertNotNil(self.viewModel);
}

- (void)testGenders {
    NSArray * genders = [self.viewModel genders];
    XCTAssertEqual(genders.count, 2);
    XCTAssertTrue([[genders objectAtIndex:0] isKindOfClass:NSString.class]);
}

/* unstable test
- (void)testSelectGender {
    
    XCTestExpectation *expectation =
    [self expectationWithDescription:@"SelectGender"];
    
    [self.viewModel didSelectIndex:0 withCompletion:^(BOOL success) {
        XCTAssertTrue(success);
        [expectation fulfill];
    }];
   
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
         XCTAssertNil(error);
    }];
}
*/

@end
