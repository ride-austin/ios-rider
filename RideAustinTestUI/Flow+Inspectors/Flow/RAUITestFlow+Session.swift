//
//  RAUITestFlow+Common.swift
//  Ride
//
//  Created by Marcos Alba on 25/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

// Session behavior (Sign In, Sign Out, Sign Up)

extension RAUITestFlow {
    
    func signIn(_ user: Account){
        let signIn = splashHelper.signInButton
        testCase.waitForElementToAppear(element: signIn, timeout: 30)
        signIn.tap()
        
        let emailSearchField = loginHelper.emailTextField
        emailSearchField.tap()
        emailSearchField.typeText(user.username)
        
        let passwordSecureTextField = loginHelper.passwordTextField
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(user.password)
        
        loginHelper.doneButton.tap()
    }
    
    func signInSuccess(){
        signIn(TestUser1)
        
        testCase.passedWhenElementAppears(element: mapHelper.setPickUpButton, timeout: 15)
    }
    
    func signInInvalid(){
        signIn(TestUserInvalid)
        
        testCase.passedWhenElementAppears(element: loginHelper.signInFailedAlert)
    }
    
    func signInDisabled(){
        signIn(TestUserDisabled)
        
        let signInFailedAlert = loginHelper.signInFailedAlert
        testCase.passedWhenElementAppears(element: signInFailedAlert)
        
        let elementPredicate = NSPredicate(format: "label beginsWith[cd] 'Account is disabled. Please contact support.'")
        XCTAssertTrue(signInFailedAlert.staticTexts.element(matching: elementPredicate).exists)
    }
    
    func signInInactive(){
        signIn(TestUserInactive)
        testCase.passedWhenElementAppears(element: mapHelper.setPickUpButton, timeout: 50)
    }
    
    func signInNetworkFailed(){
        signIn(TestUserNetworkFailed)
        
        let signInFailedAlert = loginHelper.signInFailedAlert
        testCase.passedWhenElementAppears(element: signInFailedAlert)
        
        let labelPredicate = NSPredicate(format: "label beginsWith[cd] 'Something went wrong. Keep calm and try again later'")
        XCTAssertTrue(signInFailedAlert.staticTexts.element(matching: labelPredicate).exists)
    }
    
    func signInNew() {
        signIn(TestUserNew)
        testCase.passedWhenElementAppears(element: mapHelper.setPickUpButton, timeout: 15)
    }
    
    func goToLoginAndSignInWithFacebook(checkPickUpButton: Bool = true){
        let signInButton = splashHelper.signInButton
        testCase.waitForElementToAppear(element: signInButton, timeout: 15)
        signInButton.tap()
        
        signInWithFacebook(checkPickUpButton: checkPickUpButton)
    }
    
    /// case 1 first time
    ///  email, password, login
    /// case 2 first time
    ///  email, login then on next screen password, login
    /// case 3 most common
    ///  continue
    /// case 4 unused facebook account
    ///  email, password, login, ok
    ///
    /// - Parameter checkPickUpButton: <#checkPickUpButton description#>
    func signInWithFacebook(checkPickUpButton: Bool = true) {
        loginHelper.facebookLoginButton.tap()
        
        //  iOS11 two taps are needed for the alert handler to fire
        //  https://stackoverflow.com/a/32228033/3040446
        app.tap()
        sleep(1)
        app.tap()
        sleep(1)
        app.tap()
        
        let tfEmail     = loginHelper.facebookWVEmailTextField
        let tfPassword  = loginHelper.facebookWVPasswordTextField
        let btnContinue = loginHelper.facebookWVContinueButton
        let btnLogin    = loginHelper.facebookWVLoginButton
        let btnOk       = loginHelper.facebookWVOKButton
        
        let predicate = NSPredicate(format: "exists == true")
        let expectationBtnContinue  = XCTNSPredicateExpectation(predicate:predicate, object:btnContinue)
        
        let resultBtnContinue = XCTWaiter().wait(for: [expectationBtnContinue], timeout: 5, enforceOrder: true)
        switch resultBtnContinue {
        case .completed:
            btnContinue.tap()
        case .timedOut:
            XCTAssertTrue(tfEmail.exists, "TextField might be displaying in arabic")
            tfEmail.tap()
            tfEmail.clearAndEnterText(text: TestUserFB.username)
            
            if !tfPassword.exists  {
                //case 2
                btnLogin.tap()
            }
            
            tfPassword.tap()
            tfPassword.clearAndEnterText(text: TestUserFB.password)
            
            btnLogin.tap()
            
            let resultBtnContinue = XCTWaiter().wait(for: [expectationBtnContinue], timeout: 10)
            switch resultBtnContinue {
            case .completed:
                btnContinue.tap()
            case .timedOut:
                //case 4
                btnOk.tap()
            default:
                break
            }
        default:
            break
        }
        
        if checkPickUpButton {
            testCase.passedWhenElementAppears(element: mapHelper.setPickUpButton, timeout: 6)
        }
    }
    
    func registerMobileForFacebookLogin() {
        let createAccountNavigationBar = registerHelper.createAccountNavBar
        testCase.waitForElementToAppear(element: createAccountNavigationBar)
        registerHelper.assertRegisterFacebookPhone()
        
        let mobileTextField = registerHelper.mobileTextField
        mobileTextField.tap()
        mobileTextField.clearAndEnterText(text: "8097689090")
        
        registerHelper.nextNavBarButton.tap()
        
        let alertTestMode = registerHelper.testModeAlert
        testCase.waitForElementToAppear(element: alertTestMode)
        alertTestMode.buttons["YES"].tap()
        
        testCase.waitForElementToAppear(element: roundUpHelper.navigationBar)
        roundUpHelper.skipButton.tap()
        
        let btnCancelDriverRegistration = driverRegistrationHelper.cancelButton
        testCase.waitForElementToAppear(element: btnCancelDriverRegistration)
        btnCancelDriverRegistration.tap()
        
        testCase.passedWhenElementAppears(element: mapHelper.setPickUpButton)
    }
    
    func signOut() {
        let menuButton = mapHelper.navigationMenuButton
        XCTAssertTrue(menuButton.exists)
        menuButton.tap()
        sleep(1) //--> use waitForElementToAppear
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Settings"].tap()
        sleep(1)//--> use waitForElementToAppear
        tablesQuery.staticTexts["Sign out"].tap()
    }
    
    func monitorFacebookPermissions() {
        if #available(iOS 11.0, *) {
            testCase.addUIInterruptionMonitor(withDescription: "facebook permissions alert") { (alert:XCUIElement) -> Bool in
                if alert.buttons.element(boundBy: 1).exists {
                    alert.buttons.element(boundBy: 1).tap()
                    return true
                }
                return false
            }
        }
    }
}
