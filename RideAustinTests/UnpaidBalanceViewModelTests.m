//
//  UnpaidBalanceViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 10/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UnpaidBalanceViewModel.h"
#import "RAUnpaidBalance.h"
#import "PaymentItem.h"
#import "ConfigUnpaidBalance.h"
#import "RACardDataModel.h"
#import "NSDictionary+JSON.h"


@interface UnpaidBalanceViewModelTests : XCTestCase

@property (nonatomic) RAUnpaidBalance *unpaidBalance;
@property (nonatomic) UnpaidBalanceViewModel *viewModel;
@property (nonatomic) PaymentItem *paymentItem;
@property (nonatomic) ConfigUnpaidBalance *config;

@end

@implementation UnpaidBalanceViewModelTests

- (void)setUp {
    [super setUp];
    
    NSDictionary *unpaidBalanceDict = @{    @"rideId"    : @12,
                                            @"amount"      : @"20",
                                            @"bevoBucksUrl"    : @"https://utdirect.utexas.edu/hfis/payBevo.WBX?s_vendor_code=RID&input=8.00&input=&input=1261099&input=&input=&input=&input=00001044&input=7",
                                            @"willChargeOn" : @10232342
                                         };
    
    NSDictionary *configDict = @{   @"enabled"        : @YES,
                                    @"title"          : @"title",
                                    @"subtitle"       : @"subtitle",
                                    @"iconSmallURL"   : @"https://media.rideaustin.com/icon/regular_seats.png",
                                    @"iconLargeURL"   : @"https://media.rideaustin.com/icon/regular_seats.png",
                                    @"warningMessage" : @"warningMessage"
                                   };
    
    self.unpaidBalance = [MTLJSONAdapter modelOfClass:RAUnpaidBalance.class fromJSONDictionary:unpaidBalanceDict error:nil];
    self.config = [MTLJSONAdapter modelOfClass:ConfigUnpaidBalance.class fromJSONDictionary:configDict error:nil];
    
    id jsonCard = [NSDictionary jsonFromResourceName:@"CARD"];
    RACardDataModel * card = [MTLJSONAdapter modelOfClass:RACardDataModel.class fromJSONDictionary:jsonCard error: nil];
    self.paymentItem = [[PaymentItem alloc] initWithCard:card];
    self.viewModel = [UnpaidBalanceViewModel modelWithBalance:self.unpaidBalance paymentMethod:self.paymentItem config:self.config];
    
}

- (void)testUnpaidBalance {
    XCTAssertNotNil(self.config);
    XCTAssertNotNil(self.unpaidBalance);
    XCTAssertNotNil(self.paymentItem);
    XCTAssertNotNil(self.viewModel);
}

- (void)testDisplayAmount {
    XCTAssertTrue([[self.viewModel displayAmount] isEqualToString:@"$20"]);
}

- (void)testAmount {
    XCTAssertTrue([[self.viewModel amount] isEqualToString:@"20"]);
}

- (void)testHeaderText {
    XCTAssertTrue([[self.viewModel headerText] isEqualToString:@"Payment Method"]);
}

- (void)testBevoUrl {
    XCTAssertTrue([self.viewModel bevoBucksUrl] == self.unpaidBalance.bevoBucksUrl);
}

- (void)testRideId {
    XCTAssertTrue([[self.viewModel rideId] isEqualToString:@"12"]);
}


@end
