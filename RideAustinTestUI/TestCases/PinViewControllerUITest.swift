//
//  PinViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 5/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class PinViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUIElements() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefault])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow(skipPhoneVerification: false)
        
        XCTAssertTrue(app.navigationBars["Verify Mobile"].exists)
        
        XCTAssertTrue(app.staticTexts["Please enter your verification code"].exists)
        XCTAssertTrue(app.staticTexts["that was sent to +18097321232"].exists)
        
        for i in 1...4 {
            XCTAssertTrue(app.textFields["digit\(i)"].exists)
        }
        let textFieldDigit = app.textFields["digit1"]
        XCTAssertTrue(textFieldDigit.value(forKey: "hasKeyboardFocus") as? Bool ?? false, "doesn't work for iOS 9")
        
        let btnResendText = app.buttons["RESEND THE TEXT"]
        XCTAssertTrue(btnResendText.exists && !btnResendText.isEnabled)
        
        let btnChangeMobilePhoneNumber = app.buttons["CHANGE MOBILE NUMBER"]
        XCTAssertTrue(btnChangeMobilePhoneNumber.exists && btnChangeMobilePhoneNumber.isEnabled)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931472
    func testSuccessVerificationCode_1931472() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefault])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow(skipPhoneVerification: false)
        waitForElementToAppear(element: app.buttons["CHANGE MOBILE NUMBER"], timeout: 15)
        
        for i in 1...4 {
            let textFieldDigit = app.textFields["digit\(i)"]
            XCTAssertTrue(textFieldDigit.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
            textFieldDigit.clearAndEnterText(text: "1")
        }
        
        let createProfileNavigationBar = app.navigationBars["CREATE A PROFILE"]
        passedWhenElementAppears(element: createProfileNavigationBar, timeout: 10)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931473
    func testResendVerificationCode_1931473() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefault])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow(skipPhoneVerification: false)
        
        let btnResendText = app.buttons["RESEND THE TEXT"]
        waitForElementToBeEnable(element: btnResendText, timeout: 25)
        btnResendText.tap()
        
        for i in 1...4 {
            let textFieldDigit = app.textFields["digit\(i)"]
            XCTAssertTrue(textFieldDigit.value(forKey: "hasKeyboardFocus") as? Bool ?? false, "doesn't work for iOS 9")
            textFieldDigit.clearAndEnterText(text: "2")
        }
        
        let createProfileNavigationBar = app.navigationBars["CREATE A PROFILE"]
        passedWhenElementAppears(element: createProfileNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931474
    func testCanChangeMobilePhoneNumber_1931474() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefault])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow(skipPhoneVerification: false)
        
        let btnChangeMobilePhoneNumber = app.buttons["CHANGE MOBILE NUMBER"]
        waitForElementToAppear(element: btnChangeMobilePhoneNumber, timeout: 15)
        btnChangeMobilePhoneNumber.tap()
        
        let createAccountNavigationBar = app.navigationBars["Create Account"]
        passedWhenElementAppears(element: createAccountNavigationBar)
        
        let elementsQuery = app.scrollViews.otherElements
        
        let emailTextField = elementsQuery.textFields["Email"]
        XCTAssertTrue(emailTextField.exists)
        XCTAssertTrue(emailTextField.value as! String == "sample@gmail.com")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931475
    func testInvalidVerificationCode_1931475() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefault])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow(skipPhoneVerification: false)
        
        for i in 1...4 {
            let textFieldDigit = app.textFields["digit\(i)"]
            XCTAssertTrue(textFieldDigit.value(forKey: "hasKeyboardFocus") as? Bool ?? false, "doesn't work for iOS 9")
            textFieldDigit.clearAndEnterText(text: "9")
        }
        
        let oppsAlert = app.alerts["Oops"]
        passedWhenElementAppears(element: oppsAlert)
        
        let predicate = NSPredicate(format: "label contains[cd] 'Phone verification error'")
        XCTAssertTrue(oppsAlert.staticTexts.element(matching: predicate).exists)
        XCTAssertTrue(oppsAlert.buttons["Dismiss"].exists)
    }
    
}
