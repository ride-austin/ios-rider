//
//  CreditCardManagmentUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 5/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class CreditCardManagmentUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931858
    func testUIElements_1931858() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToPaymentScreen()
        testFlow.creditCardManagementHelper.assertPaymentScreen()
        testFlow.creditCardManagementHelper.assertAddPaymentScreen(testCase: self)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931859
    func testCanAddCards_1931859() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToPaymentScreen()
        
        testFlow.addPaymentWithCardNumber("4242424242424242", expiration: "1220", cvc: "111") //Visa
        testFlow.addPaymentWithCardNumber("5555555555554444", expiration: "1220", cvc: "112") //Mastercard
        testFlow.addPaymentWithCardNumber("378282246310005", expiration: "1220", cvc: "3022") //American Express
        testFlow.addPaymentWithCardNumber("6011000990139424", expiration: "1220", cvc: "113") //Discover
        testFlow.addPaymentWithCardNumber("30569309025904", expiration: "1220", cvc: "114")   //Dinners Club
        testFlow.addPaymentWithCardNumber("3530111333300000", expiration: "1220", cvc: "115") //JCB
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931853
    func testInvalidCreditCardNumber_1931853() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToAddPaymentScreen()
        let app = testFlow.app
        
        let txtCardNumber = app.textFields["card number"]
        txtCardNumber.clearAndEnterText(text: "378210005822463")
        let txtCardNumberHasFocus = (txtCardNumber.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        XCTAssertTrue(txtCardNumberHasFocus)
        XCTAssertFalse(app.buttons["Save"].isEnabled)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931855
    func testPastMonthYearValidation_1931855() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToAddPaymentScreen()
        
        let app = testFlow.app
        
        let txtCardNumber = app.textFields["card number"]
        txtCardNumber.clearAndEnterText(text: "378282246310005")
        
        let txtExpiration = app.textFields["expiration date"]
        XCTAssertTrue(txtExpiration.exists)
        txtExpiration.tapAndEnter(text: "1216")
        
        let txtCVC = app.textFields["CVC"].exists ? app.textFields["CVC"] : app.textFields["CVV"]
        XCTAssertFalse(txtCVC.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
        XCTAssertFalse(app.buttons["Save"].isEnabled)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931856
    func testFutureMonthYearValidation_1931856() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        testFlow.goToAddPaymentScreen()
        testFlow.checkPaymentValidationErrorMessageWithCardNumber("378282246310005", expiration: "1285", cvc: "302", errorMessage: "Your card\\'s expiration year is invalid")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931857
    func testCreditCardNotApproved_1931857() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CREDIT_CARD_NOT_APPROVED"])
        testFlow.launchApp()
        testFlow.goToAddPaymentScreen()
        testFlow.checkPaymentValidationErrorMessageWithCardNumber("4000000000000127", expiration: "1220", cvc: "302", errorMessage: "Sorry, your credit card was not approved")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931861
    func testNotAbleToDeletePrimaryCard_1931861() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToPaymentScreen()
        let app = testFlow.app
        
        let primaryCardCell = app.tables.element.cells["Primary Card ending in 4555"]
        primaryCardCell.tap()
        
        let alert = app.alerts["Primary Credit Card"]
        passedWhenElementAppears(element: alert)
        XCTAssertTrue(alert.staticTexts["This is your primary credit card, in case you want to delete, select or add another primary card."].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931860
    func testCanChangePrimaryCard_1931860() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToPaymentScreen()
        let app = testFlow.app
        
        let firstPrimaryCard = app.tables.element.cells["Primary Card ending in 4555"]
        XCTAssertTrue(firstPrimaryCard.exists)
        
        testFlow.addPaymentWithCardNumber("5555555555554444", expiration: "1220", cvc: "112", primary: true) //Mastercard
        XCTAssertTrue(app.tables.element.cells["Primary Card ending in 4444"].exists)
        
        XCTAssertTrue(app.tables.element.cells["Card ending in 4555"].exists)
        app.tables.element.cells["Card ending in 4555"].tap()
        
        let actionSheet = app.sheets["Card Options"]
        passedWhenElementAppears(element: actionSheet)
        actionSheet.buttons["Set as primary card"].tap()
        
        waitForElementToAppear(element: app.tables.element.cells["Primary Card ending in 4555"], timeout: 15)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931862
    func testCanDeleteNonPrimaryCard_1931862() {
        let testFlow = RAUITestFlow(self,launchArguments: ["MAP_CARD_MANAGMENT_DYNAMIC"])
        testFlow.launchApp()
        testFlow.goToPaymentScreen()
        let app = testFlow.app
        
        testFlow.addPaymentWithCardNumber("3530111333300000", expiration: "1220", cvc: "115", primary: true) //JCB
        XCTAssertTrue(app.tables.element.cells["Primary Card ending in 0000"].exists)
        
        XCTAssertTrue(app.tables.element.cells["Card ending in 4555"].exists)
        app.tables.element.cells["Card ending in 4555"].tap()
        
        let actionSheet = app.sheets["Card Options"]
        passedWhenElementAppears(element: actionSheet)
        
        let btnDeleteCard = actionSheet.buttons["Delete Card"]
        XCTAssertTrue(btnDeleteCard.exists)
        btnDeleteCard.tap()
        
        let deleteConfirmationAlert = app.alerts["Delete Confirmation"]
        passedWhenElementAppears(element: deleteConfirmationAlert)
        XCTAssertTrue(deleteConfirmationAlert.staticTexts["Are you sure you want to delete this credit card?"].exists)
        deleteConfirmationAlert.buttons["Yes"].tap()
    }
    
}
