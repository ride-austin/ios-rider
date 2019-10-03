//
//  LostItemViewModelTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 16/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LostItemViewModel.h"
#import "LIOptionDataModel.h"
#import "LIFieldViewModel.h"

@interface LostItemViewModelTests : XCTestCase

@property (nonatomic) LostItemViewModel *viewModel;

@end

@implementation LostItemViewModelTests

- (void)setUp {
    self.viewModel = [LostItemViewModel testViewModel];
}

- (void)testViewModelNotNil {
    XCTAssertNotNil(self.viewModel);
}

- (void)testActionTypeButton {
    XCTAssertEqual([self.viewModel actionButtonType], ActionButtonReportItemLost);
}

- (void)testViewModelProperties {
    XCTAssertTrue([[self.viewModel title] isEqualToString:@"I couldn't reach my driver about a lost item"]);
    XCTAssertTrue([[self.viewModel headerText] isEqualToString:@"Tell us more"]);
    XCTAssertTrue([[self.viewModel actionTitle] isEqualToString:@"Submit"]);

}

- (void)testFieldViewModel{
    
    XCTAssertTrue([[self.viewModel fields] count] > 0);
    LIFieldViewModel * fieldViewModel = [[self.viewModel fields] objectAtIndex:0];
    XCTAssertTrue([fieldViewModel rowType] == XLFormRowDescriptorTypeBaseXLTextViewCell);
    XCTAssertTrue([[fieldViewModel requireMsg] isEqualToString:@"Please input Test text"]);
}

@end
