//
//  LostItemsUITest.swift
//  Ride
//
//  Created by Theodore Gonzalez on 6/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class LostItemsUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932064
    func test1LostItemOptionAccessibleFromTripHistory_1932064() {
        let flow = RAUITestFlow(self)
        flow.launchAppToMapInInitialState()
        flow.tapOnMenu()
        
        let tablesQuery = flow.appTables
        tablesQuery.cells.staticTexts["Trip History / Support"].tap()
        
        flow.app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        
        tablesQuery.cells.staticTexts["I lost an item"].tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932065
    func test2LookAndFeel_1932065() {
        let testCase = "https://testrail.devfactory.com//index.php?/tests/view/1932065"
        let flow = RAUITestFlow(self)
        let inspector = flow.supportTableVCInspector
        XCTAssertTrue(inspector.cellOption1.exists, testCase)
        XCTAssertTrue(inspector.cellOption2.exists, testCase)
        XCTAssertTrue(inspector.cellOption3.exists, testCase)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932067
    func test3ContactDriverLookAndFeel_1932067() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        flow.supportTableVCInspector.cellOption1.tap()
        passedWhenElementAppears(element: inspector.navBarTellUsMore)
        
        inspector.bodyCellContactMyDriver.swipeUp()
        inspector.submitButton.tap()
        
        let validationMessage = "Please input Phone number"
        let validationAlert = inspector.app.alerts.staticTexts[validationMessage]
        passedWhenElementAppears(element: validationAlert)
        let dismissButton = inspector.app.alerts.buttons["Dismiss"]
        dismissButton.tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932068
    func test4ContactDriverNumberValidations_1932068() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        inspector.submitButton.tap()
        
        let validationMessage = "Please input Phone number"
        let validationAlert = inspector.app.alerts.staticTexts[validationMessage]
        passedWhenElementAppears(element: validationAlert)
        inspector.alertDismissButton.tap()
        
        //  need to validate country code attachment
        //  need to validate failed phone
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932069
    func test5SubmitNumberAndInitiateCall_1932069() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        
        inspector.phoneTextField.tap()
        inspector.phoneTextField.typeText("565362043")
        inspector.submitButton.tap()
        
        passedWhenElementAppears(element: inspector.contactDriverSuccessAlert)
        inspector.alertDismissButton.tap()
        
        passedWhenElementAppears(element: flow.supportTableVCInspector.navBarIlostAnItem)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932071
    func test6CouldNotReachDriverLookAndFeel_1932071() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        flow.supportTableVCInspector.cellOption2.tap()
        passedWhenElementAppears(element: inspector.navBarTellUsMore)
        
        inspector.bodyCellICouldntReachDriver.swipeUp()
        inspector.submitButton.tap()
        
        let validationMessage = "Please input Item description"
        let validationAlert = inspector.app.alerts.staticTexts[validationMessage]
        passedWhenElementAppears(element: validationAlert)
        inspector.alertDismissButton.tap()
        
        inspector.itemDescriptionCell.tap()
        inspector.itemDescriptionTextView.typeText("sample description")
        inspector.itemDescriptionTextView.deleteText()
        
        inspector.submitButton.tap()
        passedWhenElementAppears(element: validationAlert)
        inspector.alertDismissButton.tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932072
    func test7CouldNotReachDriverItemDescriptionValidation_1932072() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        
        inspector.itemDescriptionCell.tap()
        inspector.itemDescriptionTextView.typeText("sample description")
        inspector.submitButton.tap()
        
        let validationMessage = "Please input Share details"
        let validationAlert = inspector.app.alerts.staticTexts[validationMessage]
        passedWhenElementAppears(element: validationAlert)
        inspector.alertDismissButton.tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932074
    func test8CouldNotReachDriverGrantPermissionSelectNo_1932074() {
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        
        inspector.shareDetailsCell.tap()
        inspector.shareDetailsTextView.typeText("sample share details")
        inspector.nextButton.tap()
        
        inspector.app.pickers.pickerWheels["Yes"].tap()
        inspector.nextButton.tap()
        
        inspector.phoneTextField.typeText("565362043")
        
        inspector.doneButton.tap()
        inspector.submitButton.tap()
        
        passedWhenElementAppears(element: inspector.submitLostItemSuccessAlert)
        inspector.alertDismissButton.tap()
        
        passedWhenElementAppears(element: flow.supportTableVCInspector.navBarIlostAnItem)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1932073
    func test9CouldNotReachDriverDescriptionAndShareDetailsChracterLimits_1932073() {
        let testCase = "https://testrail.devfactory.com//index.php?/tests/view/10203623"
        let flow = RAUITestFlow(self)
        let inspector = flow.lostItemsFormVCInspector
        flow.supportTableVCInspector.cellOption2.tap()
        passedWhenElementAppears(element: inspector.navBarTellUsMore)
        
        inspector.bodyCellICouldntReachDriver.swipeUp()
        
        let fifty = "01234567890123456789012345678901234567890123456789"
        let threeHundredCharacters = "\(fifty)\(fifty)\(fifty)\(fifty)\(fifty)\(fifty)"
        inspector.itemDescriptionCell.tap()
        inspector.itemDescriptionTextView.typeText(threeHundredCharacters)
        let allowedDescription = inspector.itemDescriptionTextView.value as! String
        XCTAssertTrue(allowedDescription.count == 255, testCase)
        
        inspector.shareDetailsCell.tap()
        inspector.shareDetailsTextView.typeText(threeHundredCharacters)
        let allowedDetails = inspector.shareDetailsTextView.value as! String
        XCTAssertTrue(allowedDetails.count == 255, testCase)
    }

    // https://testrail.devfactory.com//index.php?/tests/view/10203618
    func DISABLED_test10203618skipped() {
        //  parameters are validated in test10203613 and test10203616, additional phone validation is done on server side
    }
    
    // https://testrail.devfactory.com//index.php?/tests/view/10203619
    func DISABLED_test10203619skipped() {
        //  parameters are validated in test10203616, email sent should be confirmed server side
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10203627
    func DISABLED_test10203627skipped() {
        //  parameters are validated in test10203616, server side handles email
    }
}
