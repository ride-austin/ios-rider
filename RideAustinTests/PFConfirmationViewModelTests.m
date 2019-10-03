//
//  PFConfirmationViewModelTests.m
//  RideAustinTests
//
//  Created by Roberto Abreu on 10/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PFConfirmationViewModel.h"
#import "RACarCategoryDataModel.h"

@interface PFConfirmationViewModelTests : XCTestCase

@property (nonatomic) PFConfirmationViewModel *priorityFareConfirmationViewModel;

@end

@implementation PFConfirmationViewModelTests

- (void)setUp {
    [super setUp];
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:[self defaultCategory]];
}

- (RASurgeAreaDataModel*)defaultSurgeArea {
    NSDictionary *surgeAreaDict = @{ @"name" : @"SurgeSample",
                                     @"carCategoriesFactors" : @{ @"REGULAR" : @(2.351),
                                                                  @"SUV"     : @(3.404),
                                                                  @"PREMIUM" : @(5.205),
                                                                  @"LUX"     : @(4.277)
                                                                  }
                                     };
    return [[RASurgeAreaDataModel alloc] initWithDictionary:surgeAreaDict error:nil];
}


- (RACarCategoryDataModel*)defaultCategory {
    RACarCategoryDataModel *category = [[RACarCategoryDataModel alloc] init];
    category.carCategory = @"REGULAR";
    category.baseFare = @(1.50);
    category.minimumFare = @(2.50);
    category.ratePerMinute = @(3.25);
    category.ratePerMile = @(2.12);
    [category processSurgeAreas:@[[self defaultSurgeArea]]];
    return category;
}

- (void)testTitleEqualPriorityFare {
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.title, @"Priority Fare");
}

- (void)testSurgeFactorText {
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.surgeFactorText, @"2.35x");
    
    RACarCategoryDataModel *suvCategory = [self defaultCategory];
    suvCategory.carCategory = @"SUV";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:suvCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.surgeFactorText, @"3.4x");
    
    RACarCategoryDataModel *premiumCategory = [self defaultCategory];
    premiumCategory.carCategory = @"PREMIUM";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:premiumCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.surgeFactorText, @"5.2x");
    
    RACarCategoryDataModel *luxCategory = [self defaultCategory];
    luxCategory.carCategory = @"LUX";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:luxCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.surgeFactorText, @"4.28x");
}

- (void)testMinimumFare {
    NSString *minimumFare = [self.priorityFareConfirmationViewModel minimumFare].string;
    XCTAssertEqualObjects(minimumFare, @"$5.88 MINIMUM FARE");
    
    RACarCategoryDataModel *premiumCategory = [self defaultCategory];
    premiumCategory.carCategory = @"PREMIUM";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:premiumCategory];
    minimumFare = [self.priorityFareConfirmationViewModel minimumFare].string;
    XCTAssertEqualObjects(minimumFare, @"$13.01 MINIMUM FARE");
}

- (void)testRatePerMinute {
    NSString *ratePerMinute = [self.priorityFareConfirmationViewModel min].string;
    XCTAssertEqualObjects(ratePerMinute, @"$7.64 / MIN");
    
    RACarCategoryDataModel *luxCategory = [self defaultCategory];
    luxCategory.carCategory = @"LUX";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:luxCategory];
    ratePerMinute = [self.priorityFareConfirmationViewModel min].string;
    XCTAssertEqualObjects(ratePerMinute, @"$13.90 / MIN");
}

- (void)testRatePerMile {
    NSString *ratePerMile = [self.priorityFareConfirmationViewModel mile].string;
    XCTAssertEqualObjects(ratePerMile, @"$4.98 / MILE");
    
    RACarCategoryDataModel *suvCategory = [self defaultCategory];
    suvCategory.carCategory = @"SUV";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:suvCategory];
    ratePerMile = [self.priorityFareConfirmationViewModel mile].string;
    XCTAssertEqualObjects(ratePerMile, @"$7.22 / MILE");
}

- (void)testWholeNumberToType {
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.wholeNumberToType, @"2");
    
    RACarCategoryDataModel *luxCategory = [self defaultCategory];
    luxCategory.carCategory = @"LUX";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:luxCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.wholeNumberToType, @"4");
}

- (void)testDecimalNumberToType {
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.decimalToType, @"35");
    
    RACarCategoryDataModel *luxCategory = [self defaultCategory];
    luxCategory.carCategory = @"LUX";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:luxCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.decimalToType, @"28");
}

- (void)testNumberToTypeDescription {
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.numberToTypeDescription, @"Type (2.35)\nTo confirm your priority multiplier");
    
    RACarCategoryDataModel *premiumCategory = [self defaultCategory];
    premiumCategory.carCategory = @"PREMIUM";
    self.priorityFareConfirmationViewModel = [PFConfirmationViewModel viewModelWithCategory:premiumCategory];
    XCTAssertEqualObjects(self.priorityFareConfirmationViewModel.numberToTypeDescription, @"Type (5.2)\nTo confirm your priority multiplier");
}

- (void)testNumberTypedValidation {
    XCTAssertTrue([self.priorityFareConfirmationViewModel isValidWholeNumber:@"2" andDecimal:@"35"]);
    XCTAssertFalse([self.priorityFareConfirmationViewModel isValidWholeNumber:@"2" andDecimal:@"20"]);
    XCTAssertFalse([self.priorityFareConfirmationViewModel isValidWholeNumber:@"3" andDecimal:@"35"]);
    XCTAssertFalse([self.priorityFareConfirmationViewModel isValidWholeNumber:@"1" andDecimal:@"16"]);
}

@end
