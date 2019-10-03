//
//  RegisterViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RegisterViewControllerUITest: XCTestCase {
   
    override func setUp() {
        super.setUp()
        continueAfterFailure = false;
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931465
    func testRegisterValidation_1931465() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        let btnRegister = testFlow.splashHelper.registerButton
        waitForElementToAppear(element: btnRegister, timeout: 15)
        btnRegister.tap()
        
        let nextButton = app.navigationBars["Create Account"].buttons["NEXT"]
        nextButton.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        let phoneTextField = elementsQuery.textFields["Phone"]
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        
        //Test empty form
        let oopsAlert = app.alerts["Oops"]
        XCTAssertTrue(oopsAlert.staticTexts["Please enter your email address."].exists, "Doesn't match error message")
        
        let dismissButton = oopsAlert.buttons["Dismiss"]
        dismissButton.tap()
        
        //Test invalid email
        emailTextField.tap()
        emailTextField.typeText("sax.com")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Please enter a valid email address."].exists, "Invalid email message not shown or match")
        dismissButton.tap()
        
        //Test empty phon
        emailTextField.clearAndEnterText(text: "sax@gmail.com")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Please enter a valid mobile phone number. i.e Minimum 8 digits and Max 15 digits"].exists)
        dismissButton.tap()
        
        //Test min & max digits phone number
        phoneTextField.tap()
        phoneTextField.typeText("11")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Please enter a valid mobile phone number. i.e Minimum 8 digits and Max 15 digits"].exists)
        dismissButton.tap()
        phoneTextField.clearAndEnterText(text: "111111111111111")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Please enter a valid mobile phone number. i.e Minimum 8 digits and Max 15 digits"].exists)
        dismissButton.tap()
        
        //Test empty password
        phoneTextField.clearAndEnterText(text: "8097898765")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Please enter a password."].exists)
        dismissButton.tap()
        
        //Test min password
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123")
        nextButton.tap()
        XCTAssertTrue(oopsAlert.staticTexts["Your password needs to be at least 6 characters long."].exists)
        dismissButton.tap()
        
        //Test correct lenght password
        passwordSecureTextField.clearAndEnterText(text: "123456")
        nextButton.tap()
        XCTAssertTrue(app.alerts["Please confirm your email address"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931463
    func testRegistrationSuccess_1931463() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        testFlow.doRegistrationFlow()
        
        let createProfileScreen = app.navigationBars["CREATE A PROFILE"]
        waitForElementToAppear(element: app.navigationBars["CREATE A PROFILE"])

        let firstNameTextField = app.textFields["First Name"]
        firstNameTextField.tap()
        firstNameTextField.typeText("Marc Anthony")

        let lastNameTextField = app.textFields["Last Name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("Alonzo")
        
        createProfileScreen.buttons["NEXT"].tap()

        let roundUpNavigationBar = app.navigationBars["Round up"]
        waitForElementToAppear(element: roundUpNavigationBar)
        roundUpNavigationBar.buttons["Skip"].tap()

        let driverRegistrationScreen = app.staticTexts["Interested in becoming a driver?"]
        waitForElementToAppear(element: driverRegistrationScreen)
        app.buttons["CANCEL"].tap()

        let locationviewNavigationBar = app.navigationBars["LocationViewControllerNavigationBar"]
        passedWhenElementAppears(element: locationviewNavigationBar)
    }
    
    func checkExistenceFlow(mapArgument:String,matchErrorText:String)->(app:XCUIApplication, errorEmailExisting:XCUIElement) {
        let testFlow = RAUITestFlow(self,launchArguments: [mapArgument])
        testFlow.launchApp()
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        testFlow.doRegistrationFlow(isSuccessful: false)
        
        let errorExisting = app.alerts["OOPS"]
        waitForElementToAppear(element: errorExisting)
        let msgErrorPredicate = NSPredicate(format: "label beginsWith[cd] '\(matchErrorText)'")
        let msgErrorElement = errorExisting.staticTexts.element(matching: msgErrorPredicate)
        XCTAssertTrue(msgErrorElement.exists)
        return (app, errorExisting)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931466
    func testExistingEmail_1931466() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_EMAIL", matchErrorText: "\"This email address is already in use\"")
        errorExisting.buttons["Login"].tap()
        
        let signInNavigationBar = app.navigationBars["Sign In"]
        passedWhenElementAppears(element: signInNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931467
    func testExistingEmailThenChooseEdit_1931467() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_EMAIL", matchErrorText: "\"This email address is already in use\"")
        errorExisting.buttons["Edit"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        XCTAssertTrue(emailTextField.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931468
    func testExistingPhone_1931468() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_PHONE", matchErrorText: "\"This phone number is already in use\"")
        errorExisting.buttons["Login"].tap()
        
        let signInNavigationBar = app.navigationBars["Sign In"]
        passedWhenElementAppears(element: signInNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931469
    func testExistingPhoneThenChooseEdit_1931469() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_PHONE", matchErrorText: "\"This phone number is already in use\"")
        errorExisting.buttons["Edit"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let phoneTextField = elementsQuery.textFields["Phone"]
        XCTAssertTrue(phoneTextField.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
    }
    
    func testExistingEmailAndPhone() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_EMAIL_PHONE", matchErrorText: "\"These email and phone number are already in use\"")
        errorExisting.buttons["Login"].tap()
        
        let signInNavigationBar = app.navigationBars["Sign In"]
        passedWhenElementAppears(element: signInNavigationBar)
    }
    
    func testExistingEmailAndPhoneThenChooseEdit() {
        let (app, errorExisting) = checkExistenceFlow(mapArgument:"MAP_REGISTRATION_EXISTING_EMAIL_PHONE", matchErrorText: "\"These email and phone number are already in use\"")
        errorExisting.buttons["Edit"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        XCTAssertTrue(emailTextField.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931464
    func testRegisterFacebookSuccess_1931464() {
        let testFlow = RAUITestFlow(self)
        testFlow.monitorFacebookPermissions()
        testFlow.launchApp()
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        let btnRegister = app.buttons["REGISTER"]
        waitForElementToAppear(element: btnRegister, timeout: 15)
        btnRegister.tap()
        
        testFlow.signInWithFacebook(checkPickUpButton: true)
    }
    
    func testRegisterFacebookNoPhoneNumber() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_LOGIN_FACEBOOK_SUCCESS_NO_PHONE"])
        testFlow.monitorFacebookPermissions()
        testFlow.launchApp()
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        let btnRegister = app.buttons["REGISTER"]
        waitForElementToAppear(element: btnRegister, timeout: 15)
        btnRegister.tap()
        
        testFlow.signInWithFacebook(checkPickUpButton: false)
        
        let createAccountNavigationBar = app.navigationBars["Create Account"]
        waitForElementToAppear(element: createAccountNavigationBar, timeout: 5)
        XCTAssertTrue(app.staticTexts["Enter Your Phone Number"].exists)
        XCTAssertTrue(app.staticTexts["Get text messages when your car arrives, let drivers contact you to organize pickup, and get help getting back lost items."].exists)
        
        let mobileTextField = app.textFields["Mobile"]
        mobileTextField.tap()
        mobileTextField.clearAndEnterText(text: "8097689090")
        
        createAccountNavigationBar.buttons["NEXT"].tap()
        
        let alertTestMode = app.alerts["TEST MODE"]
        waitForElementToAppear(element: alertTestMode, timeout: 5)
        alertTestMode.buttons["YES"].tap()
        
        let roundUpScreen = app.navigationBars["Round up"]
        waitForElementToAppear(element: roundUpScreen, timeout: 5)
        roundUpScreen.buttons["Skip"].tap()
        
        let btnCancelDriverRegistration = app.buttons["CANCEL"]
        waitForElementToAppear(element: btnCancelDriverRegistration, timeout: 5)
        btnCancelDriverRegistration.tap()
        
        let setPickupBtn = app.buttons["SET PICKUP LOCATION"]
        passedWhenElementAppears(element: setPickupBtn, timeout: 5)
    }
    
}
