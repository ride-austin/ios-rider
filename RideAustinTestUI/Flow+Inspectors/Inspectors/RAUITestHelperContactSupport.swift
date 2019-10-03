//
//  RAUITestHelperContactSupport.swift
//  RideAustinTestUI
//
//  Created by Roberto Abreu on 1/11/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperContactSupport: RAUITestBaseHelper {
    
    //MARK: Properties
    
    var helpBar: XCUIElement {
        return app.otherElements["helpBar"]
    }
    
    var contactSupportNavigationBar: XCUIElement {
        return app.navigationBars["CONTACT SUPPORT"]
    }
    
    var contactSupportMessageTextView: XCUIElement {
        return app.textViews["supportMessage"]
    }
    
}

