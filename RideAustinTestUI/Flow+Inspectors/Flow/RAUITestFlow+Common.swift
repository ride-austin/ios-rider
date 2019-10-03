//
//  RAUITestFlow+Common.swift
//  Ride
//
//  Created by Marcos Alba on 25/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

// General purpose

import XCTest

extension RAUITestFlow {
    
    var yesButton: XCUIElement {
        return app.buttons["Yes"]
    }
    
    var noButton: XCUIElement {
        return app.buttons["No"]
    }
    
    func tapYesIfExists() {
        if yesButton.exists {
            yesButton.tap()
        }
    }
    
    func tapNoIfExists() {
        if noButton.exists {
            noButton.tap()
        }
    }
    
    func staticTexts(_ text: String) -> XCUIElement {
        return app.staticTexts[text]
    }
    
    var appTables: XCUIElementQuery {
        return app.tables
    }

}
