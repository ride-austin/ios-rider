//
//  ForgotPasswordViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class ForgotPasswordViewControllerUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func goToForgotPasswordScreen(app:XCUIApplication) {
        let signIn = app.buttons["SIGN IN"]
        waitForElementToAppear(element: signIn, timeout: 15)
        signIn.tap()
        
        app.buttons["Forgot Password"].tap()
    }
    
    func testUIElements() {
        let app = XCUIApplication(launchArguments: [])
        app.launch()
        
        goToForgotPasswordScreen(app: app)
        
        let navigationTitle = app.navigationBars["Forgot Password"]
        XCTAssertTrue(navigationTitle.exists)
        
        let lblInformation = app.staticTexts["Enter your email address and we'll send you a link to reset your password."]
        XCTAssertTrue(lblInformation.exists)
        
        let txtEmail = app.textFields["Email"]
        XCTAssertTrue(txtEmail.exists)
        
        let btnResetPassword = app.buttons["Reset Password"]
        XCTAssertTrue(btnResetPassword.exists)
    }
    
    func testValidationEmail() {
        let app = XCUIApplication(launchArguments: [])
        app.launch()
        
        goToForgotPasswordScreen(app: app)
        
        //Validate empty email
        let resetPasswordButton = app.buttons["Reset Password"]
        resetPasswordButton.tap()
        let sorryAlert = app.alerts["Sorry"]
        XCTAssertTrue(sorryAlert.exists, "Alert asking email address not visible")
        XCTAssertTrue(sorryAlert.staticTexts["Please enter your email address."].exists, "Message of alert doesn't match")
        sorryAlert.buttons["Dismiss"].tap()
        
        //Validate no valid email format
        let txtEmail = app.textFields["Email"]
        txtEmail.tap()
        txtEmail.typeText("no-valid-email")
        resetPasswordButton.tap()
        XCTAssertTrue(sorryAlert.exists,"Alert asking valid email address not visible")
        XCTAssertTrue(sorryAlert.staticTexts["Please enter a valid email address."].exists, "Message of alert doesn't match")
        sorryAlert.buttons["Dismiss"].tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931280
    func testForgotPasswordSuccess_1931280() {
        let app = XCUIApplication(launchArguments: [])
        app.launch()
        
        goToForgotPasswordScreen(app: app)
        
        let txtEmail = app.textFields["Email"]
        txtEmail.tap()
        txtEmail.typeText("mysamplexx@gmail.com")
        
        let resetPasswordButton = app.buttons["Reset Password"]
        resetPasswordButton.tap()
        
        let signInNavigationtitle = app.navigationBars["Sign In"]
        passedWhenElementAppears(element: signInNavigationtitle, timeout: 5)
    }
    
    func testForgotPasswordNonExistingEmail() {
        let app = XCUIApplication(launchArguments: ["MAP_FORGOT_PASSWORD_NO_EXISTING_EMAIL"])
        app.launch()
        
        goToForgotPasswordScreen(app: app)
        
        let txtEmail = app.textFields["Email"]
        txtEmail.tap()
        txtEmail.typeText("sample@gmail.com")
        
        let resetPasswordButton = app.buttons["Reset Password"]
        resetPasswordButton.tap()
        
        let sorryAlert = app.alerts["Oops"]
        passedWhenElementAppears(element: sorryAlert, timeout: 5)
        let msgErrorPredicate = NSPredicate(format: "label beginsWith[cd] 'User not found'")
        let msgErrorElement = sorryAlert.staticTexts.element(matching: msgErrorPredicate)
        XCTAssertTrue(msgErrorElement.exists)
    }

}
