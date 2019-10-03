//
//  RatingViewModelTests.m
//  RideAustinTests
//
//  Created by Roberto Abreu on 10/31/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+Utils.h"
#import "RASessionManager.h"
#import "RatingViewModel.h"
#import "UnratedRideManager.h"

@interface RatingViewModelTests : XCTestCase

@property (nonatomic) RatingViewModel *ratingViewModel;

@end

@implementation RatingViewModelTests

- (void)setUp {
    [super setUp];
    
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE" ofType:@"json"] error:nil];
    ride.completedDate = [NSDate trueDate];
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    
    ConfigGlobal *configGlobal = [MTLJSONAdapter modelOfClass:[ConfigGlobal class] fromJSONDictionary:[self parseFile:@"CONFIG_GLOBAL_200" ofType:@"json"] error:nil];
    [ConfigurationManager shared].global = configGlobal;
    
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
}

- (id)parseFile:(NSString*)fileName ofType:(NSString*)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}

- (void)testDriverPhotoURL {
    XCTAssertNotNil(self.ratingViewModel.driverPhotoURL);
}

- (void)testCommentTitle {
    XCTAssertEqualObjects(self.ratingViewModel.commentTitle, @"What feedback would you give Nick Name?");
    
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE" ofType:@"json"] error:nil];
    ride.activeDriver.driver.user.nickName = nil;
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
    
    NSString *message = [NSString stringWithFormat:@"What feedback would you give %@?", ride.activeDriver.driver.firstname];
    XCTAssertEqualObjects(self.ratingViewModel.commentTitle, message);
}

- (void)testSummaryDescription {
    XCTAssertEqualObjects(self.ratingViewModel.summaryDescription, @"Eligible credits will be applied on your emailed receipt.");
    
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE" ofType:@"json"] error:nil];
    ride.freeCreditCharged = [NSNumber numberWithDouble:3.0];
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
    
    XCTAssertEqualObjects(self.ratingViewModel.summaryDescription, @"Eligible credits have been applied.");
}

- (void)testTotalLabel {
    XCTAssertEqualObjects(self.ratingViewModel.totalLabel, @"$ 8.00");
    
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE" ofType:@"json"] error:nil];
    ride.requestedCarType = [MTLJSONAdapter modelOfClass:[RACarCategoryDataModel class] fromJSONDictionary:[self parseFile:@"CATEGORY" ofType:@"json"] error:nil];
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
    
    XCTAssertEqualObjects(self.ratingViewModel.totalLabel, @"Free");
}

- (void)testMaxCommentLength {
    XCTAssertEqual(self.ratingViewModel.maxCommentLength, 1200);
}

- (void)testLimitValueToAskConfirmation {
    XCTAssertEqual(self.ratingViewModel.limitValueToAskConfirmation, 50.0);
}

- (void)testTipConfirmationMessage {
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE" ofType:@"json"] error:nil];
    ride.requestedCarType = [MTLJSONAdapter modelOfClass:[RACarCategoryDataModel class] fromJSONDictionary:[self parseFile:@"CATEGORY" ofType:@"json"] error:nil];
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
    
    unratedRide.userTip = @"80";
    XCTAssertEqualObjects(self.ratingViewModel.tipConfirmationMessage, @"Please confirm that you are tipping $80.00");
    
    unratedRide.userTip = @"60";
    XCTAssertEqualObjects(self.ratingViewModel.tipConfirmationMessage, @"Please confirm that you are tipping $60.00");
}

- (void)testTipValueByIndex {
    XCTAssertNil([self.ratingViewModel tipForIndex:0]);
    XCTAssertEqualObjects([self.ratingViewModel tipForIndex:1], @"1");
    XCTAssertEqualObjects([self.ratingViewModel tipForIndex:2], @"2");
    XCTAssertEqualObjects([self.ratingViewModel tipForIndex:3], @"5");
    XCTAssertNil([self.ratingViewModel tipForIndex:4]);
}

- (void)testCanEnableSubmitButton {
    XCTAssertFalse(self.ratingViewModel.canEnableSubmitButton);
    
    self.ratingViewModel.rating = 3;
    XCTAssertFalse(self.ratingViewModel.canEnableSubmitButton);
    
    self.ratingViewModel.rating = 0;
    self.ratingViewModel.selectedTipIndex = 0;
    XCTAssertFalse(self.ratingViewModel.canEnableSubmitButton);
    
    self.ratingViewModel.rating = 4;
    XCTAssertTrue(self.ratingViewModel.canEnableSubmitButton);
}

- (void)testShouldNotShowTipWhenCategoryDisabledTipping {
    RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:[self parseFile:@"RIDE_NO_TIPPING" ofType:@"json"] error:nil];
    UnratedRide *unratedRide = [[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodPrimaryCreditCard];
    
    self.ratingViewModel = [[RatingViewModel alloc] initWithRide:unratedRide configuration:[ConfigurationManager shared]];
    XCTAssertFalse(self.ratingViewModel.shouldShowTip);
}

//- (void)testShouldShowTipByAllowableDelay {
//    [UnratedRideManager shared].allowableDelay = [NSNumber numberWithInteger:5.0];
//    XCTAssertTrue(self.ratingViewModel.shouldShowTip);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for allowable delay"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UnratedRideManager shared].allowableDelay = [NSNumber numberWithInteger:5.0];
//        XCTAssertFalse(self.ratingViewModel.shouldShowTip);
//        [expectation fulfill];
//    });
//    [self waitForExpectationsWithTimeout:10 handler:nil];
//}

@end
