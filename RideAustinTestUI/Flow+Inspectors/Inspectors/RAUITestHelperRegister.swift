//
//  RAUITestHelperRegister.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperRegister: RAUITestBaseHelper {

    //MARK: Properties
    var createAccountNavBar: XCUIElement {
        return app.navigationBars["Create Account"]
    }
    
    var nextNavBarButton: XCUIElement {
        return createAccountNavBar.buttons["NEXT"]
    }

    var mobileTextField: XCUIElement {
        return app.textFields["Mobile"]
    }
    
    var testModeAlert: XCUIElement {
        return app.alerts["TEST MODE"]
    }
    
    //MARK: Methods
    func assertRegisterFacebookPhone() {
        XCTAssertTrue(app.staticTexts["Enter Your Phone Number"].exists)
        XCTAssertTrue(app.staticTexts["Get text messages when your car arrives, let drivers contact you to organize pickup, and get help getting back lost items."].exists)
    }
    
}
