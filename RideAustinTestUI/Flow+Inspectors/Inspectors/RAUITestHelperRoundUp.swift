//
//  RAUITestHelperRoundUp.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperRoundUp: RAUITestBaseHelper {
    
    //MARK: Properties
    var navigationBar: XCUIElement {
        return app.navigationBars["Round up"]
    }
    
    var skipButton: XCUIElement {
        return navigationBar.buttons["Skip"]
    }
    
    var roundUpAlert: XCUIElement {
        return app.staticTexts["Round-Up"]
    }
    
    var btnRoundUpNoAlert: XCUIElement {
        return app.buttons["No"]
    }
    
}
