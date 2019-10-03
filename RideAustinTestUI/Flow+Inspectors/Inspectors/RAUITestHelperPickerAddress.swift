//
//  RAUITestHelperPickerAddressViewController.swift
//  RideAustinTestUI
//
//  Created by Roberto Abreu on 10/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperPickerAdddress:RAUITestBaseHelper {
    
    //MARK: Properties
    
    var txtAddress: XCUIElement {
        return app.textFields.element(matching: .textField, identifier: "txtAddress")
    }
    
    var tblAddressResult: XCUIElement {
        return app.tables.element(matching: .table, identifier: "tblAddressResult")
    }
    
    var recentPlaceCells: [XCUIElement] {
        let addFavoritePredicate = NSPredicate(format: "label != %@ && label != %@", "Add Home", "Add Work")
        let favoritePredicate = NSPredicate(format: "label != %@ && label != %@", "Home", "Work")
        let optionPredicate = NSPredicate(format: "label != %@ && label != %@", "Set Location On Map", "Remove Destination")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [addFavoritePredicate, favoritePredicate, optionPredicate])
        return tblAddressResult.cells.matching(predicate).allElementsBoundByIndex
    }
    
}
