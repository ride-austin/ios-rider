//
//  SplitFareModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 08/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SplitFare.h"

@interface SplitFareModelTests : XCTestCase

@property (nonatomic) SplitFare *splitFare;

@end

@implementation SplitFareModelTests

- (void)setUp {
    [super setUp];
    
    NSDictionary *splitDictionary = @{ @"rideId"     : @1,
                                       @"riderFullName"  : @"testName",
                                       @"riderPhoto" : @"photo",
                                       @"status"     : @"REQUESTED",
                                       @"sourceRiderFullName" : @"sourceName",
                                       @"sourceRiderPhotoURL" : @"sourcePhoto"
                                      };
    
    self.splitFare = [MTLJSONAdapter modelOfClass:SplitFare.class fromJSONDictionary:splitDictionary error:nil];
}

- (void)testNotNil {
    XCTAssertNotNil(self.splitFare);
}

- (void)testProperties {
    XCTAssertEqual(self.splitFare.riderName, @"testName",@"Rider name not correct");
    XCTAssertEqual(self.splitFare.riderPhoto, @"photo",@"Rider photo not correct");
    XCTAssertEqual(self.splitFare.sourceRiderName, @"sourceName",@"Source name not correct");
    XCTAssertEqual(self.splitFare.sourceRiderPhoto, @"sourcePhoto",@"Source photo not correct");
    XCTAssertEqual(self.splitFare.status, SFStatusRequested);
};


@end
