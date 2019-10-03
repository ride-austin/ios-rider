//
//  PromotionsViewModelTests.m
//  Ride
//
//  Created by Roberto Abreu on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PromotionsViewModel.h"

@interface PromotionsViewModelTests : XCTestCase

@property (nonatomic) ConfigGlobal *configGlobal;
@property (nonatomic) PromotionsViewModel *promotionsViewModel;
@property (nonatomic) NSMutableDictionary *promoCreditsDictionary;

@end

@implementation PromotionsViewModelTests

- (void)setUp {
    [super setUp];
    self.configGlobal = [[ConfigGlobal alloc] init];
    self.promotionsViewModel = [[PromotionsViewModel alloc] initWithConfiguration:self.configGlobal];
    
    //PromoCredits JSON Mapping
    //Used because properties of ConfigPromoCredits are read-only
    self.promoCreditsDictionary = [NSMutableDictionary dictionary];
    self.promoCreditsDictionary[@"title"] = @"Credits Balance";
    self.promoCreditsDictionary[@"detailTitle"] = @"Credits Available";
    self.promoCreditsDictionary[@"showTotal"] = @(YES);
    self.promoCreditsDictionary[@"showDetail"] = @(YES);
    self.promoCreditsDictionary[@"termDescription"] = @"Terms & conditions apply. See original promotion for expiration term, and discounts applicable per trip.";
}

- (void)testReferFriendEnabled {
    NSDictionary *dict = @{ @"enabled" : @(YES) };
    ConfigReferRider *configReferFriend = [[ConfigReferRider alloc] initWithDictionary:dict error:nil];
    self.configGlobal.referRider = configReferFriend;
    XCTAssertTrue(self.promotionsViewModel.isReferFriendAvailable);
    XCTAssertEqual(self.promotionsViewModel.referFriendHeightContainer, 219.0);
    XCTAssertEqual(self.promotionsViewModel.creditBalanceTopOffset, 24.0);
}

- (void)testReferFriendHidden {
    //Not ReferFriend Config
    [self assertReferFriendHidden];
    
    //Disabled ReferFriend Config
    NSDictionary *dict = @{ @"enabled" : @(NO) };
    ConfigReferRider *configReferFriend = [[ConfigReferRider alloc] initWithDictionary:dict error:nil];
    self.configGlobal.referRider = configReferFriend;
    [self assertReferFriendHidden];
}

- (void)assertReferFriendHidden {
    XCTAssertFalse(self.promotionsViewModel.isReferFriendAvailable);
    XCTAssertEqual(self.promotionsViewModel.referFriendHeightContainer, 0.0);
    XCTAssertEqual(self.promotionsViewModel.creditBalanceTopOffset, 0.0);
}

- (void)testCreditBalanceEnabled {
    ConfigPromoCredits *promoCredits = [[ConfigPromoCredits alloc] initWithDictionary:self.promoCreditsDictionary error:nil];
    self.configGlobal.promoCredits = promoCredits;
    XCTAssertTrue(self.promotionsViewModel.isCreditBalanceAvailable);
    XCTAssertEqual(self.promotionsViewModel.creditBalanceHeightContainer, 80.0);
    XCTAssertEqual(self.promotionsViewModel.creditTitle, @"Credits Balance");
}

- (void)testCreditBalanceHidden {
    //Not PromoCredit Config
    [self assertCreditBalanceHidden];
    
    //Disabled PromoCredit
    self.promoCreditsDictionary[@"showTotal"] = @(NO);
    ConfigPromoCredits *promoCredits = [[ConfigPromoCredits alloc] initWithDictionary:self.promoCreditsDictionary error:nil];
    self.configGlobal.promoCredits = promoCredits;
    [self assertCreditBalanceHidden];
}

- (void)assertCreditBalanceHidden {
    XCTAssertFalse(self.promotionsViewModel.isCreditBalanceAvailable);
    XCTAssertFalse(self.promotionsViewModel.isCreditBalanceDetailAvailable);
    XCTAssertEqual(self.promotionsViewModel.creditBalanceHeightContainer, 0.0);
    XCTAssertNil(self.promotionsViewModel.creditTitle);
}

- (void)testBalanceDetailEnabled {
    ConfigPromoCredits *promoCredits = [[ConfigPromoCredits alloc] initWithDictionary:self.promoCreditsDictionary error:nil];
    self.configGlobal.promoCredits = promoCredits;
    XCTAssertTrue(self.promotionsViewModel.isCreditBalanceAvailable && promoCredits.showDetail);
}

- (void)testBalanceDetailDisabled {
    //Not PromoCredit Config
    XCTAssertFalse(self.promotionsViewModel.isCreditBalanceDetailAvailable);
    
    //Disabled PromoCredit Details
    self.promoCreditsDictionary[@"showDetail"] = @(NO);
    ConfigPromoCredits *promoCredits = [[ConfigPromoCredits alloc] initWithDictionary:self.promoCreditsDictionary error:nil];
    self.configGlobal.promoCredits = promoCredits;
    XCTAssertFalse(self.promotionsViewModel.isCreditBalanceDetailAvailable);
}

@end
