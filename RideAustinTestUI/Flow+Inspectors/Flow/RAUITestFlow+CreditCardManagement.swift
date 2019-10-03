//
//  RAUITestFlow+Cards.swift
//  Ride
//
//  Created by Roberto Abreu on 5/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

extension RAUITestFlow {
    
    func goToPaymentScreen() {
        signInSuccess()
        
        let menuButton = mapHelper.navigationMenuButton
        XCTAssertTrue(menuButton.exists)
        menuButton.tap()
        
        let paymentCell = appTables.staticTexts["Payment"]
        testCase.passedWhenElementAppears(element: paymentCell, timeout: 2)
        paymentCell.tap()
        
        let navigationBarPayment = app.navigationBars.matching(identifier: "Payment").firstMatch
        testCase.passedWhenElementAppears(element: navigationBarPayment)
    }
    
    func goToAddPaymentScreen() {
        goToPaymentScreen()
        creditCardManagementHelper.addPaymentCell.tap()
    }
    
    func addPaymentWithCardNumber(_ cardNumber:String,expiration:String,cvc:String,primary:Bool=false) {
        self.creditCardManagementHelper.addPaymentFromTestCase(testCase, cardNumber: cardNumber, expiration: expiration, cvc: cvc,primary: primary)
    }
    
    func checkPaymentValidationErrorMessageWithCardNumber(_ cardNumber:String,expiration:String,cvc:String,errorMessage:String) {
        creditCardManagementHelper.txtCardNumber.clearAndEnterText(text: cardNumber)
        
        let txtExpiration = creditCardManagementHelper.txtExpirationDate
        XCTAssertTrue(txtExpiration.exists)
        txtExpiration.tapAndEnter(text: expiration)
        
        let txtCVC = creditCardManagementHelper.txtCVC
        XCTAssertTrue(txtCVC.value(forKey: "hasKeyboardFocus") as? Bool ?? false)
        txtCVC.tapAndEnter(text: cvc)
        
        let btnSave = creditCardManagementHelper.btnSaveCard
        XCTAssertTrue(btnSave.isEnabled)
        btnSave.tap()
        
        let alert = app.alerts["Oops"]
        testCase.passedWhenElementAppears(element: alert, timeout: 30)
        let elementPredicate = NSPredicate(format: "label contains[cd] '\(errorMessage)'")
        XCTAssertTrue(alert.staticTexts.element(matching: elementPredicate).exists)
    }
    
}
