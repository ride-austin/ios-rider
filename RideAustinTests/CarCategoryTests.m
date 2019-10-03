//
//  CarCategoryTests.m
//  Ride
//
//  Created by Roberto Abreu on 4/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RASurgeAreaDataModel.h"
#import "NSDictionary+JSON.h"
#import "RACarCategoryDataModel.h"

@interface CarCategoryTests : XCTestCase

@property (nonatomic) RACarCategoryDataModel *sampleCategory;
@property (nonatomic) RASurgeAreaDataModel *surgeAreaA;
@property (nonatomic) RASurgeAreaDataModel *surgeAreaB;
@property (nonatomic) RASurgeAreaDataModel *surgeAreaC;

@end

@implementation CarCategoryTests

- (void)setUp {
    [super setUp];
    
    NSError *modelError;
    
    NSDictionary *suvJSON = [NSDictionary jsonFromResourceName:@"CarCategorySUV" error:&modelError];
    self.sampleCategory = [MTLJSONAdapter modelOfClass:[RACarCategoryDataModel class] fromJSONDictionary:suvJSON[@"requestedCarType"] error:&modelError];
    
    //SurgeArea A
    NSDictionary *surgeAreaAParams = @{ @"id" : @1,
                                        @"name" : @"77019",
                                        @"csvGeometry" : @"-95.38910508155823,29.7582582670846 -95.38580060005188,29.758304837050307 -95.38572549819946,29.757569029061706 -95.38900852203369,29.757531772817348",
                                        @"carCategoriesFactors" : @{ @"REGULAR" : @2.00,
                                                                     @"SUV"     : @2.00,
                                                                     @"LUXURY"  : @1.00,
                                                                     @"PREMIUM" : @1.00 }
                                        };
    self.surgeAreaA = [MTLJSONAdapter modelOfClass:[RASurgeAreaDataModel class] fromJSONDictionary:surgeAreaAParams error:&modelError];
    
    //SurgeArea B
    NSDictionary *surgeAreaBParams = @{ @"id" : @2,
                                        @"name" : @"77019",
                                        @"csvGeometry" : @"-95.39917945861816,29.76370680620866 -95.39823532104492,29.760353894116392 -95.3983211517334,29.756702817797294 -95.39806365966797,29.753051608461853 -95.39754867553711,29.751039660766413 -95.39505958557129,29.747760844664032 -95.39299964904785,29.745823312016157 -95.3891372680664,29.74567426949237 -95.38261413574219,29.745599748147384 -95.3774642944336,29.74567426949237 -95.37394523620605,29.745525226747034 -95.37034034729004,29.74589783319499 -95.36802291870117,29.74589783319499 -95.36622047424316,29.745972354318408 -95.36613464355474,29.762738198684357",
                                        @"carCategoriesFactors" : @{ @"REGULAR" : @1.00,
                                                                     @"SUV"     : @3.00,
                                                                     @"LUXURY"  : @3.00,
                                                                     @"PREMIUM" : @1.00 }
                                        };
    self.surgeAreaB = [MTLJSONAdapter modelOfClass:[RASurgeAreaDataModel class] fromJSONDictionary:surgeAreaBParams error:&modelError];
    
    //SurgeArea C
    NSDictionary *surgeAreaCParams = @{ @"id" : @3,
                                        @"name" : @"77019",
                                        @"csvGeometry" : @"-95.38910508155823,29.7582582670846 -95.38580060005188,29.758304837050307 -95.38572549819946,29.757569029061706 -95.38900852203369,29.757531772817348",
                                        @"carCategoriesFactors" : @{ @"REGULAR" : @2.00,
                                                                     @"SUV"     : @1.00,
                                                                     @"LUXURY"  : @1.00,
                                                                     @"PREMIUM" : @1.00 }
                                      };
    self.surgeAreaC = [MTLJSONAdapter modelOfClass:[RASurgeAreaDataModel class] fromJSONDictionary:surgeAreaCParams error:&modelError];
}

- (void)testCategoryProcessSurgeAreas {
    [self.sampleCategory processSurgeAreas:@[self.surgeAreaA,self.surgeAreaB]];
    XCTAssertEqual(self.sampleCategory.surgeAreas.count, 2, @"The category should has 2 surge areas");
}

- (void)testCategoryHasAPriority {
    [self.sampleCategory processSurgeAreas:@[self.surgeAreaA]];
    XCTAssertTrue(self.sampleCategory.hasPriority, @"Category should has a priority");
}

- (void)testCategoryNotHasPriority {
    XCTAssertFalse(self.sampleCategory.hasPriority, @"Category should not has a priority");
}

- (void)testCategoryReplaceRepeatSurgeArea {
    [self.sampleCategory processSurgeAreas:@[self.surgeAreaA]];
    
    NSDictionary *surgeAreaAParams = @{ @"id" : @1,
                                        @"name" : @"77019",
                                        @"csvGeometry" : @"-95.38910508155823,29.7582582670846 -95.38580060005188,29.758304837050307 -95.38572549819946,29.757569029061706 -95.38900852203369,29.757531772817348",
                                        @"carCategoriesFactors" : @{ @"REGULAR" : @8.00,
                                                                     @"SUV"     : @8.00,
                                                                     @"LUXURY"  : @8.00,
                                                                     @"PREMIUM" : @8.00 }
                                        };
    RASurgeAreaDataModel *surgeAreaATmp = [MTLJSONAdapter modelOfClass:[RASurgeAreaDataModel class] fromJSONDictionary:surgeAreaAParams error:nil];
    
    [self.sampleCategory processSurgeAreas:@[surgeAreaATmp]];
    XCTAssertEqual(self.sampleCategory.surgeAreas.count, 1, @"Should be just one surge area");
    XCTAssertEqual(self.sampleCategory.factorForHighestSurgeArea, 8.0, @"The surge factor should be 8.0");
}

- (void)testCategoryReturnHighestSurgeArea {
    [self.sampleCategory processSurgeAreas:@[self.surgeAreaA,self.surgeAreaB]];
    XCTAssertEqualObjects(self.sampleCategory.highestSurgeArea, self.surgeAreaB, @"Should return surgeAreaB, because has the higher factor");
}

- (void)testCategoryNotReturnSurgeAreaWhenIsNormal {
    NSDictionary *surgeAreaAParams = @{ @"id" : @1,
                                        @"name" : @"77019",
                                        @"csvGeometry" : @"-95.38910508155823,29.7582582670846 -95.38580060005188,29.758304837050307 -95.38572549819946,29.757569029061706 -95.38900852203369,29.757531772817348",
                                        @"carCategoriesFactors" : @{ @"REGULAR" : @1.00,
                                                                     @"SUV"     : @1.00,
                                                                     @"LUXURY"  : @1.00,
                                                                     @"PREMIUM" : @1.00 }
                                        };
    RASurgeAreaDataModel *surgeDataModel = [MTLJSONAdapter modelOfClass:[RASurgeAreaDataModel class] fromJSONDictionary:surgeAreaAParams error:nil];
    
    [self.sampleCategory processSurgeAreas:@[surgeDataModel]];
    XCTAssertNil(self.sampleCategory.highestSurgeArea, @"Should not have highest surge area");
}

- (void)testCategoryCanCleanAllSurgeAreas {
    [self.sampleCategory processSurgeAreas:@[self.surgeAreaA, self.surgeAreaB]];
    [self.sampleCategory clearSurgeAreas];
    XCTAssertEqual(self.sampleCategory.surgeAreas.count, 0, @"Should not be any surge area");
}

@end
