//
//  LoginViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 4/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class LoginViewControllerUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931276
    func testLoginSuccess_1931276() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        testFlow.signInSuccess()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931277
    func testLoginFailed_1931277() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_LOGIN_FAILED"])
        testFlow.launchApp()
        testFlow.signInInvalid()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931283
    func testLoginNetworkFailed_1931283() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_LOGIN_NETWORK_FAILED"])
        testFlow.launchApp()
        testFlow.signInInvalid()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931279
    func testLoginFacebookRegisteredUser_1931279() {
        let testFlow = RAUITestFlow(self)
        testFlow.monitorFacebookPermissions()
        testFlow.launchApp()
        testFlow.goToLoginAndSignInWithFacebook()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931281
    func testLoginFacebookNoPhoneNumber_1931281() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_LOGIN_FACEBOOK_SUCCESS_NO_PHONE"])
        testFlow.monitorFacebookPermissions()
        testFlow.launchApp()
        testFlow.goToLoginAndSignInWithFacebook(checkPickUpButton:  false)
        testFlow.registerMobileForFacebookLogin()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931278
    func testLoginDisabledUser_1931278() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_LOGIN_DISABLED"])
        testFlow.launchApp()
        testFlow.signInDisabled()        
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931282
    func testLoginInactiveUser_1931282() {
        let testFlow = RAUITestFlow(self,launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationRealAuth,"MAP_LOGIN_INACTIVE"])
        testFlow.launchApp()
        testFlow.signInInactive()
        
        testFlow.tapNoIfExists()
        waitForElementToBeHittable(element: testFlow.mapHelper.setPickUpButton, timeout: 50)
        testFlow.forceTapOnPickUpButton()
        testFlow.tapOnRequestRideButton()
        
        testFlow.tryPushNotificationReminder()
        
        let inactiveAlert = testFlow.app.alerts["Oops"]
        waitForElementToAppear(element: inactiveAlert, timeout: 15)
        let predicate = NSPredicate(format: "label contains[cd] 'Your account is not yet active. Please retry after some time.'")
        let inactiveMessage = inactiveAlert.staticTexts.element(matching: predicate)
        XCTAssertTrue(inactiveMessage.exists)
    }
    
}
