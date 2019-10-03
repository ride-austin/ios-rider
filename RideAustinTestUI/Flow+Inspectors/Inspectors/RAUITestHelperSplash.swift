//
//  RAUITestHelperSplash.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperSplash: RAUITestBaseHelper {
    
    //MARK: Properties
    var splashView: XCUIElement {
        return app.otherElements["Splash"]
    }
    
    var bgImage: XCUIElement {
        return app.images["splashBgImage"]
    }
    
    var logoImage: XCUIElement {
        return app.images["splashLogoImage"]
    }
    
    var signInButton: XCUIElement {
        return app.buttons["SIGN IN"]
    }
    
    var registerButton: XCUIElement {
        return app.buttons["REGISTER"]
    }
    
    var versionLabel: XCUIElement {
        return app.staticTexts["splashVersionLabel"]
    }
    
    var waitingHUD: XCUIElement {
        return app.otherElements["WAITING FOR INTERNET CONNECTION..."]
    }

    //MARK: Methods
    func assertSplashView() {
        XCTAssertTrue(bgImage.exists)
        XCTAssertTrue(logoImage.exists)
        XCTAssertTrue(signInButton.exists)
        XCTAssertTrue(registerButton.exists)
        XCTAssertTrue(versionLabel.exists)
    }
    
}
