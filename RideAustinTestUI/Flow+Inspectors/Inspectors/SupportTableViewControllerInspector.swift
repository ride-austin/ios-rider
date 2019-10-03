//
//  SupportTableViewControllerInspector.swift
//  Ride
//
//  Created by Theodore Gonzalez on 6/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class SupportTableViewControllerInspector: RAUITestBaseHelper {
    
    var tablesQuery: XCUIElementQuery {
        return app.tables
    }
    
    var navBarIlostAnItem: XCUIElement {
        if #available(iOS 11.0, *) {
            return app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH 'I lost an item'"))
        } else {
            return app.navigationBars.staticTexts["I lost an item"]
        }
    }
    
    var cellOption1: XCUIElement {
        return tablesQuery.cells.staticTexts["Contact my driver about a lost item"]
    }
    
    var cellOption2: XCUIElement {
        return tablesQuery.cells.staticTexts["I couldn't reach my driver about a lost item"]
    }
    
    var cellOption3: XCUIElement {
        return tablesQuery.cells.staticTexts["Returned lost items"]
    }
    
}
