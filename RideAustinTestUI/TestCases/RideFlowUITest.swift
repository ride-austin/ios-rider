//
//  RideFlowUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 4/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RideFlowUITest: XCTestCase {
 
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication(launchArguments: [])
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRideSuccess() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState(withUser: TestUser1)
        testFlow.mapHelper.setPickUpButton.tap()
        testFlow.waitForMapChangingToState(.Confirmation, timeout: 15)
        testFlow.tapOnRequestRideButton()
        
        tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting, timeout: 5)
        passedWhenElementAppears(element: testFlow.mapHelper.cancelRequestingRideButton)
        
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 15)
        testFlow.waitForMapChangingToState(.DriverReached, timeout: 15)
        testFlow.waitForMapChangingToState(.Riding, timeout: 30)
        
        self.passedWhenElementAppears(element: testFlow.ratingHelper.submitButton, timeout: 50)
        testFlow.ratingHelper.assertRatingView()
        testFlow.ratingHelper.rate()
        
        testFlow.waitForMapChangingToState(.Initial, timeout: 2)
    }

    func tryApplePayScreen() {
        let btDisable = app.buttons["Disable Round Up"]
        if btDisable.exists {
            btDisable.tap()
        }
    }
}
