//
//  XCUIElement+Extension.swift
//  Ride
//
//  Created by Roberto Abreu on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

extension XCUIElement {
    
    func tapClear() {
        let btClear = self.buttons["Clear text"]
        if btClear.exists {
            btClear.tap()
        }
    }
    
    func clearAndTypeText(_ text: String) {
        tapClear()
        self.tap()
        self.typeText(text)
    }
    
    func clearAndEnterText(text: String) -> Void {
        self.forceTap()
        self.deleteText()
        self.typeText(text)
    }
    
    func deleteText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        if let placeholderString = self.placeholderValue, placeholderString == stringValue {
            return //RA-15030 workaround for https://github.com/lionheart/openradar-mirror/issues/18410
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
    
    func forceTap() {
        self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
    
    func tapAndEnter(text: String) -> Void {
        self.tap()
        self.typeText(text)
    }
}
