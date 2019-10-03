//
//  TripHistoryDataModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 13/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TripHistoryDataModel.h"
#import "NSDictionary+JSON.h"


@interface TripHistoryDataModelTests : XCTestCase

@property (nonatomic) TripHistoryDataModel *history;

@end

@implementation TripHistoryDataModelTests

- (void)setUp {
    
    id jsonHistory = [NSDictionary jsonFromResourceName:@"TRIPHISTORY_MOCK"];
    self.history = [MTLJSONAdapter modelOfClass:TripHistoryDataModel.class fromJSONDictionary:jsonHistory error: nil];
}

-(void) testStatus {
    XCTAssertTrue([self.history status] == TripCompleted);
}

-(void) testCancelled {
    XCTAssertFalse([self.history isCancelled]);
}

-(void) testHasCreditInfo {
    XCTAssertTrue([self.history hasCreditCardInfo]);
}

-(void) testHasCampaign {
    XCTAssertFalse([self.history hasCampaign]);
}

/* Disable until fixed
-(void) testDateString {
    XCTAssertTrue([[self.history dateString] isEqualToString:@"01/29/2019 01:22 PM"]);
}
 */

-(void) testStatusString {
    XCTAssertTrue([[self.history statusString] isEqualToString:@"Completed"]);
}

-(void) testCarInformation {
    XCTAssertTrue([[self.history carInformation] isEqualToString:@"BMW X7"]);
}

-(void) testDisplayName {
    XCTAssertTrue([[self.history displayName] isEqualToString:@"Ar"]);
}

-(void) testRideCost {
    XCTAssertTrue([[self.history displayRideCost] isEqualToString:@"$ 8.00"]);
    XCTAssertTrue([[self.history displayTotalCharged] isEqualToString:@"$ 8.00"]);
}

@end
