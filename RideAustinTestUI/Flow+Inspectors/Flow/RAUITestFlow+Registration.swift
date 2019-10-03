//
//  RAUITestFlow+Registration.swift
//  RideAustinTestUI
//
//  Created by Roberto Abreu on 1/12/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

import XCTest

extension RAUITestFlow {
    
    func doRegistrationFlow(isSuccessful:Bool = true, skipPhoneVerification:Bool = true) {
        let btnRegister = app.buttons["REGISTER"]
        testCase.waitForElementToAppear(element: btnRegister, timeout: 15)
        btnRegister.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let emailTextField = elementsQuery.textFields["Email"]
        let phoneTextField = elementsQuery.textFields["Phone"]
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        
        emailTextField.clearAndEnterText(text: "sample@gmail.com")
        phoneTextField.clearAndEnterText(text: "8097321232")
        if #available(iOS 11.0, *) {
            passwordSecureTextField.tapAndEnter(text: "123456")
        } else {
            passwordSecureTextField.clearAndEnterText(text: "123456")
        }
        
        app.navigationBars["Create Account"].buttons["NEXT"].tap()
        
        let emailConfirmationAlert = app.alerts["Please confirm your email address"]
        XCTAssertTrue(emailConfirmationAlert.exists)
        emailConfirmationAlert.buttons["Correct"].tap()
        
        if isSuccessful {
            let pinVerificationAlert = app.alerts["TEST MODE"]
            testCase.waitForElementToAppear(element: pinVerificationAlert, timeout: 2)
            
            XCTAssertTrue(pinVerificationAlert.staticTexts["Do you want to bypass the pin verification?"].exists)
            let btConfirm = pinVerificationAlert.buttons[skipPhoneVerification ? "YES" : "NO"]
            btConfirm.tap()
        }
    }
    
    func goToDonationRegistration() {
        doRegistrationFlow()
        
        app.textFields["First Name"].clearAndEnterText(text: "Sample")
        app.textFields["Last Name"].clearAndEnterText(text: "Sample")
        app.buttons["NEXT"].tap()
        
        let roundUpScreen = app.navigationBars["Round up"]
        testCase.waitForElementToAppear(element: roundUpScreen, timeout: 5)
    }
    
    func goToDriverRegistration() {
        goToDonationRegistration()
        roundUpHelper.skipButton.tap()
        
    }
    
}
