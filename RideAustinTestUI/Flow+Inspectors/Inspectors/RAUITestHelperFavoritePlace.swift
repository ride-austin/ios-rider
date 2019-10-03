//
//  RAUITestHelperFavoritePlace.swift
//  Ride
//
//  Created by Marcos Alba on 15/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperFavoritePlace: RAUITestBaseHelper {
    
    //MARK: Properties
    var placeTextField: XCUIElement {
        return app.searchFields["placeTextField"]
    }
    
    var setPickUpButton: XCUIElement {
        return app.buttons["setLocationButton"]
    }
    
    var saveButton: XCUIElement {
        return app.buttons["Save"]
    }
    
    var backButton: XCUIElement {
        return app.buttons["Back"]
    }
    
    //MARK: Methods
    
}
