//
//  RideCommentUITest.swift
//  Ride
//
//  Created by Marcos Alba on 25/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RideCommentUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    //SetUp. https://issue-tracker.devfactory.com/browse/RA-10727
    
    func test0MapInConfirmationScreen() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("Rosedale", destination: "Hut's")
        let comment = "A comment"
        testFlow.writeComment(comment)
        sleep(2)
        let testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
    }
    
    // A. Rider is able to request a ride with comment; Rider is able to see it. https://issue-tracker.devfactory.com/browse/RA-10720
    // https://testrail.devfactory.com//index.php?/cases/view/1189857
    
    func testARequestARideWithComment() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("11624 JollyVille Road", destination: "Lamar")
        let comment = "A ride comment."
        testFlow.writeComment(comment)
        testFlow.tapOnRequestRideButton()
        testFlow.tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        let testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
    }
    
    // B. Rider is able to add comment in a requested ride; Rider is able to see it. https://issue-tracker.devfactory.com/browse/RA-10721
    // https://testrail.devfactory.com//index.php?/cases/view/1189858
    
    func testBAddCommentToaRequestedRide() {
        let testFlow = RAUITestFlow(self)
        testFlow.requestRideFrom("11624 JollyVille Road", to: "Lamar")
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 15)
        let comment = "A ride comment."
        testFlow.writeComment(comment)
        let testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
    }
    
    // C. Rider is able to update existing comment in a requested ride; Rider is able to see it. https://issue-tracker.devfactory.com/browse/RA-10722
    // https://testrail.devfactory.com//index.php?/cases/view/1189860
    
    func testCUpdateComment() {
        let testFlow = RAUITestFlow(self, configuration: XCUIApplication.XCUIAppArgumentConfigurationUpdateComment1)
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("11624 JollyVille Road", destination: "Lamar")
        var comment = "A ride comment."
        testFlow.writeComment(comment)
        testFlow.tapOnRequestRideButton()
        testFlow.tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 15)
        var testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
        testFlow.waitForMapChangingToState(.DriverReached, timeout: 10)
        comment = "Another ride comment."
        testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
    }
    
    // D. Rider is able to remove existing comment; Rider is no longer see it. https://issue-tracker.devfactory.com/browse/RA-10723
    // https://testrail.devfactory.com//index.php?/cases/view/1189861
    
    func testDRemoveComment() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("11624 JollyVille Road", destination: "Lamar")
        let comment = "A ride comment."
        testFlow.writeComment(comment)
        testFlow.tapOnRequestRideButton()
        testFlow.tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        var testComment = testFlow.getComment()
        XCTAssertTrue(testComment == comment)
        testFlow.clearComment()
        testComment = testFlow.getComment()
        if #available(iOS 11.0, *) {
            XCTAssertEqual(testComment!, "Comments for driver (e.g. building #)")
        } else {
            XCTAssertNil(testComment)
        }
    }
    
    // E. Rider adds/updates/removes comment after ride is cancelled by Driver after arriving. https://issue-tracker.devfactory.com/browse/RA-10724
    // https://testrail.devfactory.com//index.php?/cases/view/1189864
    
    func testECommentAfterRideCancelled() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration, XCUIApplication.XCUIAppArgumentConfigurationCancelledRide])
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("11624 JollyVille Road", destination: "Lamar")
        let comment = "A ride comment."
        testFlow.writeComment(comment)
        testFlow.tapOnRequestRideButton()
        testFlow.tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForMapChangingToState(.DriverReached, timeout: 10)
        
        let cancelledAlert = testFlow.app.alerts["TRIP WAS CANCELLED"]
        waitForElementToAppear(element: cancelledAlert,timeout: 15)
        sleep(2)
        cancelledAlert.buttons["Dismiss"].tap()
        
        testFlow.mapHelper.assertMapViewInState(.Initial)
    }
    
    // G. Rider adds/updates/removes comment after ride is resubmitted. https://issue-tracker.devfactory.com/browse/RA-10726
    // https://testrail.devfactory.com//index.php?/cases/view/1189866]

    func testGCommentAfterRideResubmitted() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration, XCUIApplication.XCUIAppArgumentConfigurationCancelledRideResubmitted])
        testFlow.launchAppToMapInInitialState()
        testFlow.goToConfirmationScreenWithPickUp("11624 JollyVille Road", destination: "Lamar")
        let comment = "A ride comment."
        testFlow.writeComment(comment)
        testFlow.tapOnRequestRideButton()
        testFlow.tryApplePayScreen()
        testFlow.waitForMapChangingToState(.Requesting)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 10)
        testFlow.waitForMapChangingToState(.DriverReached, timeout: 10)
        testFlow.waitForMapChangingToState(.Requesting, timeout: 15)
        testFlow.waitForMapChangingToState(.DriverOnWay, timeout: 13)
        let testComment = testFlow.getComment()
        XCTAssertEqual(testComment, comment)
    }
}
