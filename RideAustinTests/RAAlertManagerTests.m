//
//  RAAlertManagerTests.m
//  Ride
//
//  Created by Roberto Abreu on 4/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAlertManager.h"
#import <XCTest/XCTest.h>

#pragma mark - MOCK Controller

@interface MockController : UIViewController

- (UIAlertController*)showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString*)buttonTitle options:(RAAlertOption*)alertOptions;
- (UIAlertController*)showErrorAlertWithAlertItem:(id<RAAlertItem>)alertItem andOptions:(RAAlertOption*)options;

@end

@implementation MockController

- (UIAlertController*)showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString*)buttonTitle options:(RAAlertOption*)alertOptions {
    return [RAAlertManager showAlertWithTitle:title message:message options:alertOptions];
}

- (UIAlertController*)showErrorAlertWithAlertItem:(id<RAAlertItem>)alertItem andOptions:(RAAlertOption*)options {
    return [RAAlertManager showErrorWithAlertItem:alertItem andOptions:options];
}

@end

#pragma mark - TEST RAAlertManager

@interface RAAlertManagerTests : XCTestCase

@property (nonatomic) MockController *mockController;
@property (nonatomic) UIAlertController *alertController;

@end

@implementation RAAlertManagerTests

- (void)setUp {
    [super setUp];
    self.alertController = nil;
    self.mockController = [[MockController alloc] init];
    [self.mockController view];
}

- (void)tearDown {
    //Clear
    if (self.alertController) {
        [self.alertController dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.mockController = nil;
    [super tearDown];
}

- (void)testThatAlertIsShown {
    UIAlertController *alertController = [self.mockController showAlertWithTitle:@"Test" message:@"Testing Alert!" buttonTitle:@"Ok" options:nil];
    
    UIWindow *window = alertController.windowAlert;
    XCTAssertNotNil(window, @"Window should not be nil");
    XCTAssertEqual(window.windowLevel, UIWindowLevelAlert + 1, @"WindowLevel should be alert + 1");
    
    XCTAssertNotNil(window.rootViewController, @"RootViewController should not be nil");
    XCTAssertTrue([window.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]],@"PresentedViewController should be UIAlertController");
    
    [window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [RAAlertManager resetAlerts];
}

- (void)testThatAlertOverlapAnotherAlert {
    self.alertController = [self.mockController showAlertWithTitle:@"Title" message:@"Message" buttonTitle:@"Ok" options:nil];
    
    UIWindow *firstAlertWindow = [[[UIApplication sharedApplication] windows] lastObject];
    XCTAssertEqual(firstAlertWindow.windowLevel, UIWindowLevelAlert + 1,@"WindowLevel should be alert");
    
    [self.mockController showAlertWithTitle:@"Title" message:@"Message" buttonTitle:@"Ok" options:[RAAlertOption optionWithShownOption:Overlap]];
    UIWindow *secondAlertWindow = [[[UIApplication sharedApplication] windows] lastObject];
    XCTAssertEqual(secondAlertWindow.windowLevel, UIWindowLevelAlert + 1,@"WindowLevel should be alert");

    XCTAssertNotEqualObjects(firstAlertWindow, secondAlertWindow, @"Windows shoud not be the same, because overlap is active");
    [RAAlertManager resetAlerts];
}

- (void)testThatAlertAllowNetworkError {
    NSError *error = [NSError errorWithDomain:@"Error Domain" code:0 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:@"Error Suggestion"}];
    self.alertController = [self.mockController showErrorAlertWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
    
    UIWindow *window = self.alertController.windowAlert;
    XCTAssertNotNil(window, @"Window should not be nil");
    XCTAssertEqual(window.windowLevel, UIWindowLevelAlert + 1, @"WindowLevel should be UIWindowLevelAlert + 1");
    
    XCTAssertTrue([window.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]], @"PresentedViewController should be of type UIAlertController");
    
    UIAlertController *presentedAlertController = (UIAlertController*)window.rootViewController.presentedViewController;
    XCTAssertEqualObjects(presentedAlertController.message, @"Error Suggestion", @"Message of UIAlertController should be Error Suggestion");
    [RAAlertManager resetAlerts];
}

- (void)testThatAlertNotAllowNetworkError {
    NSError *error = [NSError errorWithDomain:@"Error Domain" code:-1009 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:@"Error Suggestion"}];
    self.alertController = [self.mockController showErrorAlertWithAlertItem:error andOptions:nil];
    
    XCTAssertNil(self.alertController, @"AlertController should be nil, because network error is not allow");
    [RAAlertManager resetAlerts];
}

- (void)testThatAlertReplaceContent {
    self.alertController = [self.mockController showAlertWithTitle:@"Title" message:@"Message" buttonTitle:@"Ok" options:nil];
    
    UIWindow *windowAlert = self.alertController.windowAlert;
    XCTAssertEqual(windowAlert.windowLevel, UIWindowLevelAlert + 1,@"WindowLevel should be alert");
    
    UIViewController *controller = self.alertController.windowAlert.rootViewController;
    XCTAssertNotNil(controller, @"rootViewController of Windows should not be nil");
    
    XCTAssertTrue([controller.presentedViewController isKindOfClass:[UIAlertController class]], @"PresentedViewController should be UIAlertController");
    
    [self.mockController showAlertWithTitle:@"TitleReplace" message:@"MessageReplace" buttonTitle:@"Ok" options:[RAAlertOption optionWithShownOption:ReplaceContent]];
    
    UIAlertController *presentedAlertController = (UIAlertController*)controller.presentedViewController;
    XCTAssertEqualObjects(presentedAlertController.title, @"TitleReplace", @"Current title should be TitleReplace");
    XCTAssertEqualObjects(presentedAlertController.message, @"MessageReplace", @"Current Message should be MessageReplace");
    [RAAlertManager resetAlerts];
}

- (void)testThatAnAlertWithNoneOptionIsNotPresentWithAnother {
    self.alertController = [self.mockController showAlertWithTitle:@"Title 1" message:@"Message 1" buttonTitle:@"Ok" options:nil];
    
    UIWindow *firstAlertWindow = self.alertController.windowAlert;
    XCTAssertEqual(firstAlertWindow.windowLevel, UIWindowLevelAlert + 1,@"WindowLevel should be alert");
    
    UIAlertController *secondAlertController = [self.mockController showAlertWithTitle:@"Title 2" message:@"Message 2" buttonTitle:@"Ok" options:nil];
    XCTAssertNil(secondAlertController, @"SecondAlertController should be nil, because there is already one shown");
    
    [firstAlertWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [RAAlertManager resetAlerts];
}

@end


