//
//  RequestingUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 5/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RequestingUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10379
    // https://testrail.devfactory.com/index.php?/cases/view/1931491
    func testUIElements_1931491() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        testFlow.mapHelper.setPickUpButton.tap()
        testFlow.mapHelper.assertMapViewInState(.Confirmation)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10402
    // https://testrail.devfactory.com/index.php?/cases/view/1931492
    func testCanMoveMap_1931492() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        let mapView = testFlow.mapHelper.mapView
        
        var currentValue = mapView.value as? String
        XCTAssertNotNil(currentValue);
        
        //TO DO: move map method in RAUITestFlow
        mapView.pinch(withScale: 0.9, velocity: -1)
        sleep(2)
        XCTAssertNotNil(mapView.value as? String)
        XCTAssertNotEqual(mapView.value as? String, currentValue)
        
        currentValue = mapView.value as? String
        
        mapView.pinch(withScale: 0.5, velocity: -1)
        sleep(2)
        XCTAssertNotNil(mapView.value as? String)
        XCTAssertNotEqual(mapView.value as? String, currentValue)
        
        //Zoom
        currentValue = mapView.value as? String
        XCTAssertNotNil(currentValue);
        
        //TO DO: zoom map method in RAUITestFlow
        mapView.pinch(withScale: 1.3, velocity: 1)
        sleep(2)
        XCTAssertNotNil(mapView.value as? String)
        XCTAssertNotEqual(mapView.value as? String, currentValue)
        currentValue = mapView.value as? String
        
        mapView.pinch(withScale: 1.8, velocity: 1)
        sleep(2)
        XCTAssertNotNil(mapView.value as? String)
        XCTAssertNotEqual(mapView.value as? String, currentValue)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10382
    // https://testrail.devfactory.com/index.php?/cases/view/1931512
    func testNotificationBarShownWhenNotCreditCard_1931512() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_REQUESTING_NO_CC", XCUIApplication.XCUIAppArgumentConfigurationExcludeCardsForCurrentRider])
        testFlow.launchAppToMapInInitialState()
        
        let paymentMethodNotification = testFlow.mapHelper.savePaymentMethodButton
        XCTAssertTrue(paymentMethodNotification.exists && paymentMethodNotification.isEnabled)
        paymentMethodNotification.tap()
        
        let addPaymentNavigationBar = testFlow.mapHelper.addPaymentNavBar
        passedWhenElementAppears(element: addPaymentNavigationBar, timeout: 10)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10384
    // https://testrail.devfactory.com/index.php?/cases/view/1931513
    func testCannotRequestARideWhenNotCreditCard_1931513() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_REQUESTING_NO_CC", XCUIApplication.XCUIAppArgumentConfigurationExcludeCardsForCurrentRider])
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        testFlow.mapHelper.setPickUpButton.tap()
        
        let addPaymentNavigationBar = testFlow.mapHelper.addPaymentNavBar
        passedWhenElementAppears(element: addPaymentNavigationBar, timeout: 10)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10398
    // https://testrail.devfactory.com/index.php?/cases/view/1931494
    func testActiveDriversPickupTime_1931494() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        let pickupBtn = testFlow.mapHelper.setPickUpButton
        XCTAssertTrue(pickupBtn.exists)
        XCTAssertTrue(testFlow.staticTexts("2 MIN").exists)
        
        pickupBtn.tap()
        
        let rideRequestPanel = testFlow.mapHelper.requestView
        passedWhenElementAppears(element: rideRequestPanel)
        XCTAssertTrue(rideRequestPanel.staticTexts["Pickup time is approximately 2 mins"].exists)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10399
    // https://testrail.devfactory.com/index.php?/cases/view/1931495
    func testActiveDriverPickupTimeByCategory_1931495() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        let carsPredicate = NSPredicate(format: "label beginsWith[cd] 'DRIVER'")
        let activeDrivers = testFlow.app.buttons.matching(carsPredicate)
        XCTAssertEqual(activeDrivers.count, 2)
        XCTAssertTrue(testFlow.staticTexts("2 MIN").exists)
        
        testFlow.mapHelper.SUVCarCategoryButton.tap()
        XCTAssertEqual(activeDrivers.count, 3)
        XCTAssertTrue(testFlow.staticTexts("3 MIN").exists)
        
        testFlow.mapHelper.premiumCarCategoryButton.tap()
        XCTAssertEqual(activeDrivers.count, 3)
        XCTAssertTrue(testFlow.staticTexts("4 MIN").exists)
        
        testFlow.mapHelper.luxuryCarCategoryButton.tap()
        XCTAssertEqual(activeDrivers.count, 1)
        XCTAssertTrue(testFlow.staticTexts("5 MIN").exists)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10431
    // https://testrail.devfactory.com/index.php?/cases/view/1931504
    func testCancelRideRequest_1931504() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        let pickupBtn = testFlow.mapHelper.setPickUpButton
        XCTAssertTrue(pickupBtn.exists)
        pickupBtn.tap()
        
        let rideRequestView = testFlow.mapHelper.requestView
        passedWhenElementAppears(element: rideRequestView)
        XCTAssertFalse(pickupBtn.exists)
        
        //Cancel Request from Panel
        let btnCancelRequest = testFlow.mapHelper.requestCancelButton
        XCTAssertTrue(btnCancelRequest.exists && btnCancelRequest.isEnabled)
        btnCancelRequest.tap()
        passedWhenElementAppears(element: pickupBtn)
        
        sleep(2)
        pickupBtn.tap()
        passedWhenElementAppears(element: rideRequestView)
        
        testFlow.tapOnRequestRideButton()
        
        //Check RoundUp Apple Pay Notification ~ In case disable
        let disableRoundUpAppleButton = testFlow.app.buttons["Disable Round Up"]
        if disableRoundUpAppleButton.exists {
            disableRoundUpAppleButton.tap()
        }
        
        let btnCancelRequestingBtn = testFlow.mapHelper.cancelRequestingRideButton
        passedWhenElementAppears(element: btnCancelRequestingBtn)
        btnCancelRequestingBtn.tap()
        
        let cancelAlert = testFlow.app.alerts.element(boundBy: 0)
        XCTAssertTrue(cancelAlert.staticTexts["Do you really want to cancel this ride?"].exists)
        cancelAlert.buttons["YES"].tap()
        
        sleep(5)
        XCTAssertTrue(testFlow.staticTexts("Your ride is cancelled.").exists)
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-10430
    // https://testrail.devfactory.com/index.php?/cases/view/1931505
    func testNotAvailableCars_1931505() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_REQUESTING_NOT_AVAILABLE_DRIVER"])
        testFlow.launchAppToMapInInitialState()
        sleep(5)
        
        let pickupBtn = testFlow.mapHelper.setPickUpButton
        XCTAssertTrue(pickupBtn.exists)
        pickupBtn.tap()
        
        let requestView = testFlow.mapHelper.requestView
        passedWhenElementAppears(element: requestView)
        
        testFlow.tapOnRequestRideButton()
        
        //Check RoundUp Apple Pay Notification ~ In case disable
        let disableRoundUpAppleButton = testFlow.app.buttons["Disable Round Up"]
        if disableRoundUpAppleButton.exists {
            disableRoundUpAppleButton.tap()
        }

        let noDriverAvailableAlert = testFlow.app.alerts["No Driver Available"]
        passedWhenElementAppears(element: noDriverAvailableAlert)
        XCTAssertTrue(testFlow.app.staticTexts["No drivers available right now, please try again later."].exists)
        noDriverAvailableAlert.buttons["Dismiss"].tap()

        XCTAssertTrue(requestView.exists)
    }
    
}
