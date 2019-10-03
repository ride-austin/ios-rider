//
//  RAUITestFlow+SideMenu.swift
//  Ride
//
//  Created by Marcos Alba on 20/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

// Side Menu interaction

extension RAUITestFlow {
    
    func openMenu() {
        let menuButton = mapHelper.navigationMenuButton
        self.testCase.waitForElementToAppear(element: menuButton, timeout: 15)
        menuButton.tap()
        sleep(1) //--> use waitForElementToAppear
    }
    
    func openSettings(){
        openMenu()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Settings"].tap()
        sleep(1)//--> use waitForElementToAppear
    }
    
    func goBack(){
        let backButton = mapHelper.navigatioBackButton
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        sleep(1) //--> use waitForElementToAppear
    }
    
}
