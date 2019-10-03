//
//  CarUpgradeRequestFeatureUITest.swift
//  Ride
//
//  Created by Marcos Alba on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class CarUpgradeRequestFeatureUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // 1. Receive upgrade request. https://issue-tracker.devfactory.com/browse/RA-11355
    // https://testrail.devfactory.com/index.php?/cases/view/1931782
    
    func test1ReceiveUpgradeRequest_1931782() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest()
        testFlow.pressCancelUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear()
    }
    
    // 2. Accept SUV Upgrade request. https://issue-tracker.devfactory.com/browse/RA-11357
    // https://testrail.devfactory.com/index.php?/cases/view/1931783
    
    func test2AcceptUpgradeRequest_1931783() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest(10)
        testFlow.pressConfirmUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear(10)
        testFlow.assertDriverInfoShowsCategory(.SUV)
    }

    // 3. Decline SUV Upgrade request. https://issue-tracker.devfactory.com/browse/RA-11358
    // https://testrail.devfactory.com/index.php?/cases/view/1931784
    
    func test3DeclineUpgradeRequest_1931784() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest()
        testFlow.pressDeclineUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear()
        testFlow.assertDriverInfoShowsCategory(.Standard)
    }
    
    // 4. Receive SUV Upgrade request when in other screen. https://issue-tracker.devfactory.com/browse/RA-11359
    // https://testrail.devfactory.com/index.php?/cases/view/1931785
    
    func test4AcceptUpgradeRequestWhenInOtherScreen_1931785() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVInOtherScreen, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.openSettings()
        testFlow.waitForCarUpgradeRequest(20)
        testFlow.pressConfirmUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear(10)
        testFlow.goBack()
        testFlow.assertDriverInfoShowsCategory(.SUV)
    }

    // 5. Receive SUV Upgrade cancellation from Driver before accepting. https://issue-tracker.devfactory.com/browse/RA-11365
    // https://testrail.devfactory.com/index.php?/cases/view/1931786
    
//    func test5ReceiveCancellationBeforeAccepting_1931786() {
//        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVCancelled, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
//        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
//        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
//        testFlow.waitForCarUpgradeRequest(10)
//        testFlow.waitForMapChangingToState(.DriverReached, timeout: 10)
//        testFlow.waitForCarUpgradeRequestToDisappear()
//        testFlow.waitForUpgradeCancelledAlertToAppear()
//        testFlow.assertDriverInfoShowsCategory(.Standard)
//    }

    // 6. Receive SUV Upgrade cancellation from Driver after accepting. https://issue-tracker.devfactory.com/browse/RA-11366
    // https://testrail.devfactory.com/index.php?/cases/view/1931787
    
//    func test6ReceiveCancellationAfterAccepting_1931787() {
//        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVAcceptedThenCancelled, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
//        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
//        testFlow.waitForCarUpgradeRequest(30)
//        testFlow.pressConfirmUpgradeRequest()
//        testFlow.waitForCarUpgradeRequestToDisappear(10)
//        testFlow.assertDriverInfoShowsCategory(.SUV)
//        testFlow.waitForUpgradeCancelledAlertToAppear(20)
//        testFlow.assertDriverInfoShowsCategory(.Standard)
//    }
//
    // 7. Popup closed after expired, category remains in STANDARD. https://issue-tracker.devfactory.com/browse/RA-11368
    // https://testrail.devfactory.com/index.php?/cases/view/1931788
    func test7UpgradeRequestExpired_1931788() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVExpired, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest(10)
        testFlow.waitForCarUpgradeRequestToDisappear(25)
        testFlow.waitForUpgradeExpiredAlertToAppear()
    }
    
    // 8. Accept SUV Upgrade while losing internet connection. https://issue-tracker.devfactory.com/browse/RA-11411
    // https://testrail.devfactory.com/index.php?/cases/view/1931789
    func test8AcceptUpgradeWhileNoInternet_1931789() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVWithNoNetwork, arguments: ["MAP_UPGRADE_CAR_REQUEST_NO_NETWORK","MAP_SYNCHRONIZE_RIDE_IN_COURSE"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest()
        testFlow.pressConfirmUpgradeRequest()
        testFlow.assertDriverInfoShowsCategory(.Standard)
        testFlow.waitForCarUpgradeRequest(15)
    }
    
    // 10. Priority Fare - Upgrade from Standard 1.00 to SUV 2.00. https://issue-tracker.devfactory.com/browse/RA-11414
    // https://testrail.devfactory.com/index.php?/cases/view/1931791
    
    func test10UpgradeRequestPopUpShowsPF_1931791() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest()
        testFlow.assertPriortiyFare(2.5)
    }

    // 11. Priority Fare - Upgrade from Standard 2.00 to SUV 1.00. https://issue-tracker.devfactory.com/browse/RA-11415
    // https://testrail.devfactory.com/index.php?/cases/view/1931792
    
    func test11UpgradeRequestPopUpHidesPF_1931792() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVPF1, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest()
        testFlow.assertPriortiyFare(1)
    }
    
    // 13. Cancellation fee is updated when ride is upgraded to SUV. https://issue-tracker.devfactory.com/browse/RA-11417
    // https://testrail.devfactory.com/index.php?/cases/view/1931795
    
    func test13CancellationFeeIsUpdated_1931795() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest(10)
        testFlow.pressConfirmUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear()
        testFlow.assertDriverInfoShowsCategory(.SUV)
        testFlow.showDriverInfoView()
        testFlow.cancelTrip()
        testFlow.waitForRideCancellationAlertToAppear()
        XCTAssertTrue(testFlow.cancellationFee() == 5)
    }
    
    // 14. Fare Estimate should be correct after SUV Upgrade is accepted. https://issue-tracker.devfactory.com/browse/RA-11418
    // https://testrail.devfactory.com/index.php?/cases/view/1931796
    
    func test14FareEstimateIsUpdated_1931796() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUV, arguments: ["MAP_UPGRADE_CAR_REQUEST"])
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForCarUpgradeRequest(10)
        testFlow.pressConfirmUpgradeRequest()
        testFlow.waitForCarUpgradeRequestToDisappear()
        testFlow.assertDriverInfoShowsCategory(.SUV)
        testFlow.showDriverInfoView()
        testFlow.pressFareEstimate()
        testFlow.waitForEstimatedFareViewtoAppear()
        testFlow.assertEstimatedFareIs(14.38)
    }
    
    // 20. Upgrade request when app killed. https://issue-tracker.devfactory.com/browse/RA-11426
    // https://testrail.devfactory.com/index.php?/cases/view/1931803
    
    func test20ShowUpgradePopUpWhenAppSynchronized_1931803() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpgradeToSUVStartingRideAtDriverOnWay, arguments: ["MAP_UPGRADE_CAR_REQUEST","MAP_SYNCHRONIZE_RIDE_IN_COURSE"])
        
        testFlow.launchApp()
        testFlow.signIn(TestUser1)
        testFlow.waitForCarUpgradeRequest(20)
    }
}
