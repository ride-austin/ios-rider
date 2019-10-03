//
//  StringValidationTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 12/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Valid.h"

@interface StringValidationTests : XCTestCase

@end

@implementation StringValidationTests

-(void) testValidEmail {
    NSString * email = @"testInvalidEmail.com";
    XCTAssertFalse([email isValidEmail]);
    XCTAssertFalse([email isValidEmailBasic]);
    email = @"valid@email.com";
    XCTAssertTrue([email isValidEmail]);
    XCTAssertTrue([email isValidEmailBasic]);

}

-(void) testValidEnglish {
    NSString * english = @"invalidEnglish123";
    XCTAssertFalse([english isValidEnglish]);
    english = @"validEnglish";
    XCTAssertTrue([english isValidEnglish]);
}

-(void) testValidEnglishName {
    NSString * english = @"invalidEng.lish123";
    XCTAssertFalse([english isValidEnglishName]);
    english = @"valid-English";
    XCTAssertTrue([english isValidEnglishName]);
}

-(void) testValidAlphaNumeric {
    NSString * english = @"...";
    XCTAssertFalse([english isValidAlphaNumeric]);
    english = @"valid1234";
    XCTAssertTrue([english isValidAlphaNumeric]);
}

-(void) testValidPassword {
    NSString * password = @"asdf";
    XCTAssertFalse([password isValidPassword]);
    password = @"valid1234";
    XCTAssertTrue([password isValidPassword]);
    XCTAssertTrue([[password getNumbersFromString] isEqualToString:@"1234"]);
}

-(void) testisValidConfirmationPassword {
    NSString * english = @"asdf";
    XCTAssertFalse([english isValidConfirmationPassword:@"1234"]);
    XCTAssertTrue([english isValidConfirmationPassword:@"asdf"]);
}

-(void) testValidPhone {
    NSString * phone = @"12345";
    XCTAssertFalse([phone isValidPhone]);
    XCTAssertFalse([phone isValidPhoneNumberLength]);
    phone = @"+15417543010";
    XCTAssertTrue([phone isValidPhone]);
    XCTAssertTrue([phone isValidPhoneNumberLength]);
}

@end
