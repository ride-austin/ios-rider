//
//  RAUITestHelperAddPayment.swift
//  Ride
//
//  Created by Marcos Alba on 16/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperCreditCardManagement: RAUITestBaseHelper {
    
    //MARK: Properties
    
    var tblPaymentMethods: XCUIElement {
        return app.tables.element
    }
    
    var addPaymentCell: XCUIElement {
        return tblPaymentMethods.staticTexts["Add Payment"]
    }
    
    var addPaymentNavigationBar: XCUIElement {
        return app.navigationBars["Add Payment"]
    }
    
    var lblAddPaymentBottomInformation: XCUIElement {
        return app.staticTexts["This payment method will only be charged when you request a ride"]
    }
    
    var btnSaveCard: XCUIElement {
        return app.buttons["Save"]
    }
    
    var txtCardNumber: XCUIElement {
        return app.textFields["card number"]
    }
    
    var txtExpirationDate: XCUIElement {
        return app.textFields["expiration date"]
    }
    
    var txtCVC: XCUIElement {
        return app.textFields["CVC"].exists ? app.textFields["CVC"] : app.textFields["CVV"]
    }
    
    //MARK: Methods
    
    func addPaymentFromTestCase(_ testCase:XCTestCase, cardNumber:String,expiration:String,cvc:String,primary:Bool=false) {
        let tablesQuery = app.tables.element
        app.staticTexts["Add Payment"].tap()
        let txtCardNumber = app.textFields["card number"]
        txtCardNumber.clearAndEnterText(text: cardNumber)
        
        let txtExpiration = app.textFields["expiration date"]
        XCTAssertTrue(txtExpiration.exists)
        txtExpiration.tapAndEnter(text: expiration)
        
        let txtCVC = app.textFields["CVC"].exists ? app.textFields["CVC"] : app.textFields["CVV"]
        txtCVC.tapAndEnter(text: cvc)
        
        let btnSave = app.buttons["Save"]
        XCTAssertTrue(btnSave.isEnabled)
        btnSave.tap()
        
        let alert = app.alerts["Primary Credit Card"]
        testCase.passedWhenElementAppears(element: alert)
        alert.buttons[primary ? "YES" : "NO"].tap()
        
        let lastFourDigitsIndex = cardNumber.index(cardNumber.endIndex, offsetBy: -4)
        testCase.passedWhenElementAppears(element: tablesQuery.cells.staticTexts["**** **** **** \(cardNumber.substring(from: lastFourDigitsIndex))"])
    }
    
    func assertPaymentScreen() {
        let expectedNumberOfCells:UInt = RAUITestHelperUtils.isApplePayAvailable() ? 5 : 4
        XCTAssertEqual(tblPaymentMethods.cells.count, Int(expectedNumberOfCells))
        XCTAssertTrue(tblPaymentMethods.cells["Primary Card ending in 4555"].exists)
        XCTAssertTrue(tblPaymentMethods.staticTexts["Add Payment"].exists)
        
        if RAUITestHelperUtils.isApplePayAvailable() {
            XCTAssertTrue(tblPaymentMethods.staticTexts["Apple Pay"].exists)
        }
    }
    
    func assertAddPaymentScreen(testCase:XCTestCase?) {
        addPaymentCell.tap()
        
        testCase?.waitForElementToAppear(element: addPaymentNavigationBar)
        XCTAssertTrue(lblAddPaymentBottomInformation.exists)
        
        XCTAssertTrue(btnSaveCard.exists && !btnSaveCard.isEnabled)
        
        XCTAssertTrue(txtCardNumber.exists)
        txtCardNumber.clearAndEnterText(text: "4111111111111111")
        
        XCTAssertTrue(txtExpirationDate.exists)
        txtExpirationDate.tapAndEnter(text: "1223")
        
        XCTAssertTrue(txtCVC.exists)
        txtCVC.tapAndEnter(text: "111")
        XCTAssertTrue(btnSaveCard.isEnabled)
    }
    
}

