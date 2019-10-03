//
//  LostItemsFormViewControllerInspector.swift
//  Ride
//
//  Created by Theodore Gonzalez on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class LostItemsFormViewControllerInspector: RAUITestBaseHelper {
    
}
extension LostItemsFormViewControllerInspector {
    var tablesQuery: XCUIElementQuery {
        return app.tables
    }

    var navBarTellUsMore: XCUIElement {
        if #available(iOS 11.0, *) {
            return app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH 'Tell us more'"))
        } else {
            return app.navigationBars.staticTexts["Tell us more"]
        }
    }
    
    //  Contact my driver
    var contactDriverSuccessAlert: XCUIElement {
        let successMessage = "We are now connecting you to your driver. If your driver doesn't pick up, leave a detailed voicemail describing your item and the best way to contact you."
        return app.alerts.staticTexts[successMessage]
    }
    
    var bodyCellContactMyDriver: XCUIElement {
        let formBody = "The best way to retrieve an item you may have left in a vehicle is to call the driver. Here's how:\n\n1. Scroll down and enter the phone number you would like to be contacted at. Tap submit.\n\nIf you lost your personal phone, enter a friend's phone number instead.\n\n2. We'll call the number you enter to connect you directly with your driver's mobile number.\n\nIf your driver picks up and confirms that your item has been found, coordinate a mutually convenient time and place to meet for its return to you.\n\nPlease be considerate that your driver's personal schedule will be affected by taking time out to return your item to you.\n\nDrivers are independent contractors. Neither RideAustin nor drivers are responsible for the items left in a vehicle after a trip ends. We're here to help, but cannot guarantee that a driver has your item or can immediately deliver it to you."
        return tablesQuery.cells.staticTexts[formBody]
    }
    
    //  I couldn't reach my driver about a lost item
    var itemDescriptionCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Item description"]
    }
    var itemDescriptionTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier: "Item description").textViews.element(matching: NSPredicate(format: "hasKeyboardFocus == true"))
    }
    var shareDetailsCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Share details"]
    }
    var shareDetailsTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier: "Share details").textViews.element(matching: NSPredicate(format: "hasKeyboardFocus == true"))
    }
    
    var phoneCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Enter the best phone number to reach you"]
    }
    
    var submitLostItemSuccessAlert: XCUIElement {
        let successMessage = "Thank you. We’ve received your message and we will reach out to you as soon as possible."
        return app.alerts.staticTexts[successMessage]
    }
    
    var bodyCellICouldntReachDriver: XCUIElement {
        let formBody = "Calling your driver to connect is the best way to retrieve an item you may have left in a vehicle. If you have not tried contacting your driver directly, head back and select \"Contact my driver about a lost item\".\n\nIf more than 24 hours have passed since your trip ended and you're still unable to connect with your driver, we'll step in to help. Please share some details below.\n\nDrivers are independent contractors. Neither RideAustin nor drivers are responsible for the items left in a vehicle after a trip ends. We're here to help, but cannot guarantee that a driver has your item or can immediately deliver it to you."
        return tablesQuery.cells.staticTexts[formBody]
    }
    
    //common
    var phoneTextField: XCUIElement {
        return tablesQuery.cells.textFields["phoneTextField"]
    }
    
    var submitButton: XCUIElement {
        if #available(iOS 11.0, *) {
            return tablesQuery.cells.staticTexts.element(matching: NSPredicate(format: "label BEGINSWITH 'SUBMIT'"))
        } else {
            return tablesQuery.cells.buttons["SUBMIT"]
        }
    }
    
    var alertDismissButton: XCUIElement {
        return app.alerts.buttons["Dismiss"]
    }
    
    var nextButton: XCUIElement {
        return app.toolbars.buttons.element(boundBy: 1)
    }
    var doneButton: XCUIElement {
        return app.toolbars.buttons["Done"]
    }
}
//  Validator
extension LostItemsFormViewControllerInspector {
    
}
