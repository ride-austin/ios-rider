//
//  UniversityOfTexasUnitTests.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+JSON.h"
#import "ConfigGlobal.h"
@interface UniversityOfTexasUnitTests : XCTestCase
@property (nonatomic) ConfigGlobal *globalConfig;
@end

@implementation UniversityOfTexasUnitTests

- (void)setUp {
    [super setUp];
    NSError *error = nil;
    id response = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal" error:&error];
    self.globalConfig = [MTLJSONAdapter modelOfClass:[ConfigGlobal class] fromJSONDictionary:response error:&error];
    XCTAssert(error == nil);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfigUT {
    NSError *error = nil;
    
    ConfigUT *model = self.globalConfig.ut;
    NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
    XCTAssert(error == nil);
    [self assertConfigUT:model];
    
    ConfigUT *model2 = [MTLJSONAdapter modelOfClass:[ConfigUT class] fromJSONDictionary:json error:&error];
    XCTAssert(error == nil);
    [self assertConfigUT:model2];
}
- (void)assertConfigUT:(ConfigUT *)model {
    [self assertPayWithBevoBucks:model.payWithBevoBucks];
}
- (void)assertPayWithBevoBucks:(ConfigUTPayWithBevoBucks *)model {
    XCTAssert( model.enabled == false);
    XCTAssert([model.iconLargeUrl isKindOfClass:[NSURL class]]);
    XCTAssert([model.shortDescription isKindOfClass:[NSString class]]);
    XCTAssert([model.ridePaymentDelay isEqualToNumber:@(3600)]);
}
@end
