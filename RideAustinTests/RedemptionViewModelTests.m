//
//  RedemptionViewModelTests.m
//  Ride
//
//  Created by Roberto Abreu on 9/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+Utils.h"
#import "RARedemption.h"
#import "RedemptionViewModel.h"

@interface RedemptionViewModelTests : XCTestCase

@property (nonatomic) RARedemption *redemption;

@end

@implementation RedemptionViewModelTests

- (void)setUp {
    [super setUp];
    
    NSDictionary *redemptionDict = @{ @"codeLiteral"    : @"xyzj",
                                      @"codeValue"      : @20,
                                      @"maximumUses"    : @3,
                                      @"remainingValue" : @10,
                                      @"timesUsed"      : @2,
                                      @"expiresOn"      : NSNull.null
                                    };
    
    self.redemption = [MTLJSONAdapter modelOfClass:RARedemption.class fromJSONDictionary:redemptionDict error:nil];
}

- (void)testCouponCode {
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertEqual(viewModel.couponCode, @"xyzj");
}

- (void)testCodeValueNotShowZeroDecimal {
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.value isEqualToString:@"$10"]);
}

- (void)testCodeValueShowDecimal {
    self.redemption.remainingValue = [NSNumber numberWithDouble:10.95];
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.value isEqualToString:@"$10.95"]);
}

- (void)testCouponDescriptionForOneRide {
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionUses isEqualToString:@"For your next ride"]);
}

- (void)testCouponDescriptionForMultiplesRides {
    self.redemption.maximumUses = @3;
    self.redemption.timesUsed = @1;
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionUses isEqualToString:@"For your next 2 rides"]);
    
    self.redemption.maximumUses = @10;
    self.redemption.timesUsed = @2;
    viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionUses isEqualToString:@"For your next 8 rides"]);
}

- (void)testCouponExpireTodayDescription {
    self.redemption.expiresOn = [NSDate trueDate];
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionExpiration isEqualToString:@"Expires today"]);
}

- (void)testNumberOfDaysExpiration {
    self.redemption.expiresOn = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate trueDate] options:0];
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionExpiration isEqualToString:@"Expires in 1 day"]);
    
    self.redemption.expiresOn = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:3 toDate:[NSDate trueDate] options:0];
    viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertTrue([viewModel.descriptionExpiration isEqualToString:@"Expires in 3 days"]);
}

- (void)testExpiresOnNil {
    RedemptionViewModel *viewModel = [[RedemptionViewModel alloc] initWithRedemption:self.redemption];
    XCTAssertNil(viewModel.descriptionExpiration);
}

@end
