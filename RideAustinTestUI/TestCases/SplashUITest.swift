//
//  SplashUITest.swift
//  Ride
//
//  Created by Marcos Alba on 2/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

//RA-10146: https://issue-tracker.devfactory.com/browse/RA-10146
class SplashUITest: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }

    //C1931273: https://testrail.devfactory.com/index.php?/cases/view/1931273
    //Use RA Fresh Test Automation target.
    func testSplashFromFreshInstall_1931273() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        let splashView = testFlow.splashHelper.splashView
        passedWhenElementAppears(element: splashView, timeout: 15)
        passedWhenElementAppears(element: testFlow.splashHelper.signInButton, timeout: 15)
        
        testFlow.splashHelper.assertSplashView()
    }

    //C1931274: https://testrail.devfactory.com/index.php?/cases/view/1931274
    func testSplashWhenSignout_1931274() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        testFlow.signInSuccess()
        testFlow.signOut()
        
        let splashView = testFlow.splashHelper.splashView
        passedWhenElementAppears(element: splashView,timeout: 15)

       testFlow.splashHelper.assertSplashView()
    }
    
    //C1931275: https://testrail.devfactory.com/index.php?/cases/view/1931275
    func DISABLED_testSplashOnRestartWhenInternetDown_1931275() {
        let testFlow = RAUITestFlow(self, launchEnvironment: [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoNetwork])
        testFlow.launchApp()
        
        let splashView = testFlow.splashHelper.splashView
        passedWhenElementAppears(element: splashView, timeout: 30)

        let waitingHud = testFlow.splashHelper.waitingHUD
        XCTAssertTrue(waitingHud.exists)
    }    
}
