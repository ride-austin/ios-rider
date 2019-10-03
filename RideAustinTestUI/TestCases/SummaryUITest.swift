//
//  SummaryUITest.swift
//  Ride
//
//  Created by Marcod Alba on 6/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class SummaryUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-11674
    // https://testrail.devfactory.com/index.php?/cases/view/1931700
    func test1PopupSummaryIsShownOverAnyScreen_1931700() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationSynchronizeRideAtRatingScreen, arguments: ["MAP_SYNCHRONIZE_RIDE_IN_COURSE"])
        
        testFlow.launchApp()
        testFlow.signIn(TestUser1)
        testFlow.openSettings()
        testFlow.waitForRatingView(timeout: 50)
        testFlow.tapRating()
        testFlow.tapSubmit()
    }
    
    // https://issue-tracker.devfactory.com/browse/RA-11676
    // https://testrail.devfactory.com/index.php?/cases/view/1931701
    // disabled because we are clearing all sessions on initializeUITest
    func DISABLED_test2PopUpSummaryReAppears_1931701() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationSynchronizeRideAtRatingScreen, arguments: ["MAP_SYNCHRONIZE_RIDE_IN_COURSE"])
        
        testFlow.launchApp()
        testFlow.signIn(TestUser1)
        testFlow.waitForRatingView(timeout: 50)

        testFlow.app = XCUIApplication(launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration, XCUIApplication.XCUIAppArgumentConfigurationDefault,XCUIApplication.XCUIAppArgumentConfigurationAvoidCleaningRatingCache], launchEnvironment: [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorSkipLogin])
        testFlow.launchApp()
        testFlow.waitForRatingView(timeout: 50)
        
        testFlow.tapRating()
        testFlow.tapSubmit()
    }
}
