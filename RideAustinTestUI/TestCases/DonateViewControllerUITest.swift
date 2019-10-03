//
//  DonateViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 5/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class DonateViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUIElements() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_ROUND_UP_DISABLED", XCUIApplication.XCUIAppArgumentConfigurationExcludeCharityForCurrentRider])
        testFlow.launchApp()
        
        testFlow.signInSuccess()
        
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        if app.staticTexts["Round-Up"].exists {
            app.buttons["No"].tap()
        }
    
        app.buttons["show menu"].tap()
        app.tables.staticTexts["Round Up"].tap()
        
        let roundUpScreen = app.navigationBars["Round up"]
        passedWhenElementAppears(element: roundUpScreen)
        
        let lblChooseACharity = app.staticTexts["Choose a charity"]
        
        XCTAssertFalse(lblChooseACharity.exists)
        XCTAssertTrue(app.staticTexts["Round up fare"].exists)
        XCTAssertTrue(app.staticTexts["Choose to round up the cost of your fare to help support the local community. Please select your preferred charity."].exists)
        
        let switchState = (off:"0",on:"1")
        let roundUpSwitch = app.switches["roundUpSwitch"]
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.off)
        
        let roundUpCollectionView = app.collectionViews.element(boundBy: 0)
        XCTAssertFalse(roundUpCollectionView.exists)
    
        roundUpSwitch.tap()
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.on)
        XCTAssertTrue(lblChooseACharity.exists)
        XCTAssertTrue(roundUpCollectionView.exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931482
    func testRegistrationDonation_1931482() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_ROUND_UP_DISABLED", XCUIApplication.XCUIAppArgumentConfigurationExcludeCharityForCurrentRider])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.goToDonationRegistration()
        
        let switchState = (off:"0",on:"1")
        let roundUpSwitch = app.switches["roundUpSwitch"]
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.off)
        
        roundUpSwitch.tap()
        
        let roundUpCollectionView = app.collectionViews.element(boundBy: 0)
        XCTAssertTrue(roundUpCollectionView.exists)
        let selectedCell = roundUpCollectionView.cells.containing(.staticText, identifier: "Austin Film Society").element
        selectedCell.tap()
        
        let btnCancelDriverRegistration = app.buttons["CANCEL"]
        waitForElementToAppear(element: btnCancelDriverRegistration, timeout: 5)
        btnCancelDriverRegistration.tap()
        
        let setPickupBtn = app.buttons["SET PICKUP LOCATION"]
        passedWhenElementAppears(element: setPickupBtn, timeout: 5)
        
        app.buttons["show menu"].tap()
        app.tables.staticTexts["Round Up"].tap()
        passedWhenElementAppears(element: app.navigationBars["Round up"])
        
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.on)
        XCTAssertTrue(app.staticTexts["Austin Film Society"].value as! String == "selected Austin Film Society")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932084
    func testReminderIsNotShownWhenCharitySelected_1932084() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        testFlow.signInSuccess()
        
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        XCTAssertFalse(app.staticTexts["Round-Up"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932083
    func testOpenRoundUpFromReminder_1932083() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_ROUND_UP_DISABLED", XCUIApplication.XCUIAppArgumentConfigurationExcludeCharityForCurrentRider])
        testFlow.launchApp()
        
        testFlow.signInSuccess()
        
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        let roundUpAlert = app.staticTexts["Round-Up"]
        waitForElementToAppear(element: roundUpAlert)
        XCTAssertTrue(app.staticTexts["Choose to round up the cost of your fare and the funds will be allocated to your charity of choice."].exists)
        XCTAssertTrue(app.staticTexts["Do you want to activate Round Up?"].exists)
        app.buttons["Yes"].tap()
        
        let roundUpScreen = app.navigationBars["Round up"]
        waitForElementToAppear(element: roundUpScreen, timeout: 5)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932085
    func testReminderIsShownMaximumThreeTimes_1932085() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_ROUND_UP_DISABLED", XCUIApplication.XCUIAppArgumentConfigurationExcludeCharityForCurrentRider])
        testFlow.launchApp()
        
        let roundUpAlert = testFlow.roundUpHelper.roundUpAlert
        let btnRoundUpNo = testFlow.roundUpHelper.btnRoundUpNoAlert
        
        func assertRoundUpAlert() {
            testFlow.signInSuccess()
            waitForElementToAppear(element: roundUpAlert, timeout: 30)
            btnRoundUpNo.tap()
            testFlow.signOut()
        }
        
        assertRoundUpAlert()
        assertRoundUpAlert()
        assertRoundUpAlert()
        
        testFlow.signInSuccess()
        sleep(10)
        XCTAssertFalse(roundUpAlert.exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932087
    func testChangeCharity_1932087() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_ROUND_UP_DISABLED", XCUIApplication.XCUIAppArgumentConfigurationExcludeCharityForCurrentRider])
        testFlow.launchApp()
        
        testFlow.signInSuccess()
        
        //<-- Warning: provisional
        let app: XCUIApplication = testFlow.app
        // -->
        
        func goToDonationScreen() {
            testFlow.mapHelper.navigationMenuButton.tap()
            app.tables.staticTexts["Round Up"].tap()
            let roundUpScreen = app.navigationBars["Round up"]
            passedWhenElementAppears(element: roundUpScreen)
        }
        
        XCTAssertTrue(app.staticTexts["Round-Up"].exists)
        testFlow.mapHelper.btnNoRoundUpAlert.tap()
        
        goToDonationScreen()
        
        let switchState = (off:"0",on:"1")
        let roundUpSwitch = app.switches["roundUpSwitch"]
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.off)
        roundUpSwitch.tap()
        
        let roundUpCollectionView = app.collectionViews.element(boundBy: 0)
        XCTAssertTrue(roundUpCollectionView.exists)
        var selectedCell = roundUpCollectionView.cells.containing(.staticText, identifier: "Austin Film Society").element
        selectedCell.tap()
        
        goToDonationScreen()
        
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.on)
        XCTAssertTrue(app.staticTexts["Austin Film Society"].value as! String == "selected Austin Film Society")
        
        selectedCell = roundUpCollectionView.cells.containing(.staticText, identifier: "Andy Roddick Foundation").element
        selectedCell.tap()
        
        goToDonationScreen()
        
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.on)
        XCTAssertTrue(app.staticTexts["Andy Roddick Foundation"].value as! String == "selected Andy Roddick Foundation")
        roundUpSwitch.tap()
        
        goToDonationScreen()
        XCTAssertTrue(roundUpSwitch.value as! String == switchState.off)
        XCTAssertTrue(!roundUpCollectionView.exists)
    }
    
}
