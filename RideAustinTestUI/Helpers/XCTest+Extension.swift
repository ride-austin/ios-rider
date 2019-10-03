//
//  XCTest+Extension.swift
//  Ride
//
//  Created by Roberto Abreu on 4/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        testElement(element, withPredicate: existsPredicate, timeout: timeout, file: file, line: line)
    }

    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let notExistsPredicate = NSPredicate(format: "exists == false")
        testElement(element, withPredicate: notExistsPredicate, timeout: timeout, file: file, line: line)
    }
    
    func waitForElementToHasValue(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "value != nil")
        testElement(element, withPredicate: existsPredicate, timeout: timeout, file: file, line: line)
    }
    
    func waitForElementToBeHittable(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let hittablePredicate = NSPredicate(format: "isHittable == true")
        testElement(element, withPredicate: hittablePredicate, timeout: timeout, file: file, line: line)
    }

    func waitForElementToBeEnable(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let enabledPredicate = NSPredicate(format: "enabled == true")
        testElement(element, withPredicate: enabledPredicate, timeout: timeout, file: file, line: line)
    }

    func passedWhenElementAppears(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        testElement(element, withPredicate: existsPredicate, timeout: timeout, file: file, line: line)
    }
    
    private func testElement(_ element:XCUIElement,withPredicate predicate:NSPredicate,timeout:TimeInterval, file: String, line: UInt) {
        expectation(for: predicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to \(predicate) with \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
    
}
