//
//  RAPromoCodeViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 09/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RAPromoCode.h"
#import "RAPromoViewModel.h"
#import "ConfigReferRider.h"

@interface RAPromoCodeViewModelTests : XCTestCase

@property (nonatomic) RAPromoCode *promoCode;
@property (nonatomic) ConfigReferRider *config;

@end

@implementation RAPromoCodeViewModelTests

- (void)setUp {
    
    NSDictionary *promoCodeDict = @{  @"codeLiteral" : @"testCode",
                                     @"codeValue"   : @100,
                                     @"maximunRedemption" : @10,
                                     @"currentRedemption" : @4,
                                     @"detailText" : @"details",
                                     @"emailBody" : @"body",
                                     @"smsBody" : @"smsBody",
                                     @"remainingCredit" : @6
                                      };
    
    NSDictionary *configDict = @{ @"enabled": @YES ,
                                  @"detailtexttemplate": @"Every time a new RideAustin user signs up with your invite code, they'll receive their first ride free. Once they take their first ride, you'll automatically get <codeValue> credited into your account (up to $500)",
                                  @"emailbodytemplate": @"<p>You should try RideAustin! Get <codeValue> in ride credit using my code <b><codeLiteral><b>. Download the app at: <downloadUrl></p>",
                                  @"smsbodytemplate": @"You should try RideAustin! Get <codeValue> in ride credit using my code <codeLiteral> Download the app at: <downloadUrl>",
                                  @"downloadUrl": @"www.rideaustin.com"
                                     };
    
    self.promoCode = [MTLJSONAdapter modelOfClass:RAPromoCode.class fromJSONDictionary:promoCodeDict error:nil];
    self.config = [MTLJSONAdapter modelOfClass:ConfigReferRider.class fromJSONDictionary:configDict error:nil];
    
}

- (void)testNotNil {
    XCTAssertNotNil(self.promoCode);
    XCTAssertNotNil(self.config);
}

- (void)testDownloadURL {
    
    RAPromoViewModel *viewModel = [RAPromoViewModel viewModelWithPromoCode:self.promoCode andTemplate:self.config];
    XCTAssertEqual(viewModel.downloadURL, @"www.rideaustin.com");
}

- (void)testDetailText {
    
    RAPromoViewModel *viewModel = [RAPromoViewModel viewModelWithPromoCode:self.promoCode andTemplate:self.config];
    XCTAssertTrue([viewModel.detailText isEqualToString:@"Every time a new RideAustin user signs up with your invite code, they'll receive their first ride free. Once they take their first ride, you'll automatically get $100.00 credited into your account (up to $500)"]);
}

- (void)testEmailBody {
    
    RAPromoViewModel *viewModel = [RAPromoViewModel viewModelWithPromoCode:self.promoCode andTemplate:self.config];
    XCTAssertTrue([viewModel.emailBody isEqualToString:@"<p>You should try RideAustin! Get $100.00 in ride credit using my code <b>testCode<b>. Download the app at: www.rideaustin.com</p>"]);
}

- (void)testEmailTitle {
    
    RAPromoViewModel *viewModel = [RAPromoViewModel viewModelWithPromoCode:self.promoCode andTemplate:self.config];
    XCTAssertTrue([viewModel.emailTitle isEqualToString:@"Ride Austin free credit"]);
}

- (void)testSmsBody {
    
    RAPromoViewModel *viewModel = [RAPromoViewModel viewModelWithPromoCode:self.promoCode andTemplate:self.config];
    XCTAssertTrue([viewModel.smsBody isEqualToString:@"You should try RideAustin! Get $100.00 in ride credit using my code testCode Download the app at: www.rideaustin.com"]);
}

@end
