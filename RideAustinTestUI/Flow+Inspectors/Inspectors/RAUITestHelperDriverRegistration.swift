//
//  RAUITestHelperDriverRegistration.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperDriverRegistration: RAUITestBaseHelper {
    
    //MARK: Properties
    var cancelButton: XCUIElement {
        return app.buttons["CANCEL"]
    }
    
    var registerAsDriverButton: XCUIElement {
        return app.buttons["REGISTER AS A DRIVER"]
    }
    
    var licenseAlert: XCUIElement {
        return app.alerts["RideAustin"];
    }
    
    var driverPhotoNavigationBar: XCUIElement {
        return app.navigationBars["Your Driver Photo"]
    }
    
    var navigationBarNextButton: XCUIElement {
        return app.navigationBars.buttons["NEXT"]
    }
    
    var driverPhoto: XCUIElement {
        return app.images["driverPhoto"]
    }
    
    var cameraSheet: XCUIElement {
        return app.sheets["Source"]
    }
    
    var takePhotoButton: XCUIElement {
        return app.buttons["takePhotoButton"]
    }
    
    var expirationDateTextField: XCUIElement {
        return app.textFields["txtExpirationDate"]
    }
    
    var driverPhotoConfirmation: XCUIElement {
        return app.alerts.staticTexts["Are you sure your Driver Profile Photo clearly shows your face and eyes without sunglasses?"]
    }
    
    var driverLicenseNavigationBar: XCUIElement {
        return app.navigationBars["Driver License"]
    }
    
    var chauffeurPermitNavigationBar: XCUIElement {
        return app.navigationBars["Chauffeur's Permit"]
    }
    
    var chauffeurPermitBackSideNavigationBar: XCUIElement {
        return app.navigationBars["Chauffeur's Permit Backside"]
    }
    
    var chauffeurPermitTitle: XCUIElement {
        return app.staticTexts["Chauffeur's Permit"]
    }
    
    var chauffeurPermitDescription: XCUIElement {
        return app.staticTexts["You’ll need a permit from the City Of Austin Ground Transportation Department. If you have this, upload a picture here:"]
    }
    
    var driverVehicleInformationNavigationBar: XCUIElement {
        return app.navigationBars["Vehicle Information"]
    }
    
    var continueButton: XCUIElement {
        return app.buttons["CONTINUE"]
    }
    
    var yearNavigationBar: XCUIElement {
        return app.navigationBars["Year"]
    }
    
    var registrationSticker: XCUIElement {
        return app.navigationBars["Registration Sticker"]
    }
    
    var makeNavigationBar: XCUIElement {
        return app.navigationBars["Make"]
    }
    
    var modelNavigationBar: XCUIElement {
        return app.navigationBars["Model"]
    }
    
    var colorNavigationBar: XCUIElement {
        return app.navigationBars["Color"]
    }
    
    var licensePlateNavigationBar: XCUIElement {
        return app.navigationBars["License Plate"]
    }
    
    var txtLicensePlate: XCUIElement {
        return app.textFields["txtLicensePlate"]
    }
    
    var newCarMessage: XCUIElement {
        return app.textViews["After completing the next steps, check your email for further instructions."]
    }
    
    var insuranceNavigationBar: XCUIElement {
        return app.navigationBars["Insurance"]
    }
    
    var fcraDisclosureNavigationBar: XCUIElement {
        return app.navigationBars["FCRA Disclosure"]
    }
    
    var fcraDisclosureFirstNameTextField: XCUIElement {
        return app.textFields["txtFirstName"]
    }
    
    var fcraDisclosureMiddleNameTextField: XCUIElement {
        return app.textFields["txtMiddleName"]
    }
    
    var fcraDisclosureChecboxMiddleName: XCUIElement {
        return app.buttons["checkBoxMiddleName"]
    }
    
    var fcraDisclosureLastNameTextField: XCUIElement {
        return app.textFields["txtLastName"]
    }
    
    var fcraDisclosureDateOfBirthTextField: XCUIElement {
        return app.textFields["txtDateOfBirth"]
    }
    
    var fcraDisclosureSSNTextField: XCUIElement {
        return app.textFields["txtSSN"]
    }
    
    var fcraDisclosureZipCodeTextField: XCUIElement {
        return app.textFields["txtZipCode"]
    }
    
    var fcraDisclosureDriverLicenseTextField: XCUIElement {
        return app.textFields["txtDriverLicense"]
    }
    
    var fcraDisclosureStateCodeTextField: XCUIElement {
        return app.textFields["txtStateCode"]
    }
    
    var fcraDisclosureAddressTextField: XCUIElement {
        return app.textFields["txtAddress"]
    }
    
    var fcraDisclosureCheckBoxAckReceipt: XCUIElement {
        return app.buttons["checkBoxAckReceipt"]
    }
    
    var fcraDisclosureIITitle: XCUIElement {
        return app.staticTexts["lblTitle"]
    }
    
    var fcraDisclosureIIFirstLawSummary: XCUIElement {
        return app.staticTexts["lblLawFirstSummary"]
    }
    
    var fcraDisclosureIISecondLawSummary: XCUIElement {
        return app.staticTexts["lblLawSecondSummary"]
    }
    
    var fcraDisclosureIICheckboxDescription: XCUIElement {
        return app.staticTexts["lblCheckBoxDescription"]
    }
    
    var fcraDisclosureIICheckBox: XCUIElement {
        return app.buttons["checkBox"]
    }
    
    var fcraDisclosureAckAndAuthTitle: XCUIElement {
        return app.staticTexts["lblAckAndAuthTitle"]
    }
    
    var fcraDisclosureAckAndAuthSummary: XCUIElement {
        return app.staticTexts["lblAckSummary"]
    }
    
    var fcraDisclosureElectronicSignatureTextField: XCUIElement {
        return app.textFields["txtElectronicSignature"]
    }
    
    var termAndConditionNavigationBar: XCUIElement {
        return app.navigationBars["Terms and Conditions"]
    }
    
    var termAndConditionTitle: XCUIElement {
        return app.staticTexts["lblTermTitle"]
    }
    
    var termAndConditionContent: XCUIElement {
        return app.textViews["tvTermContent"]
    }
    
    var checkBoxTermAndCondition: XCUIElement {
        return app.buttons["checkBoxTerm"]
    }
    
    var checkBoxTermAndConditionDescription: XCUIElement {
        return app.staticTexts["lblCheckBoxDescription"]
    }

    var scrollView: XCUIElement {
        return app.scrollViews.firstMatch
    }
    //MARK: Methods
    
}
