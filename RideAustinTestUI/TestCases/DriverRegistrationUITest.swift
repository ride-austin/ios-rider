//
//  DriverRegistrationUITest.swift
//  RideAustinTestUI
//
//  Created by Roberto Abreu on 1/11/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

import XCTest

class DriverRegistrationUITest: XCTestCase {
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931288
    func testWhenUserDoesntHaveLicenseDriverRegistrationExit_1931288() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        startDriverRegistration(testFlow: testFlow, buttonName: "NO")
        
        let pickupBtn = testFlow.mapHelper.setPickUpButton
        waitForElementToAppear(element: pickupBtn)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931289
    func testWhenUserHaveLicenseDriverRegistrationStart_1931289() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        startDriverRegistration(testFlow: testFlow)
        
        let driverPhotoNavigationBar = testFlow.driverRegistrationHelper.driverPhotoNavigationBar
        passedWhenElementAppears(element: driverPhotoNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931292
    func testCannotProceedWithoutAddingDriverPhoto_1931292() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        startDriverRegistration(testFlow: testFlow)
        
        let driverPhotoNavigationBar = testFlow.driverRegistrationHelper.driverPhotoNavigationBar
        passedWhenElementAppears(element: driverPhotoNavigationBar)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        let driverSignUpAlert = testFlow.app.alerts["Driver Signup"]
        waitForElementToAppear(element: driverSignUpAlert)
        XCTAssertTrue(driverSignUpAlert.staticTexts["Please upload your photo to continue."].exists)
        driverSignUpAlert.buttons["Dismiss"].tap()
        
        passedWhenElementAppears(element: driverPhotoNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931293
    func testCanRequestHelpFromDriverPhotoScreen_1931293() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        startDriverRegistration(testFlow: testFlow)
        
        let driverPhotoNavigationBar = testFlow.driverRegistrationHelper.driverPhotoNavigationBar
        passedWhenElementAppears(element: driverPhotoNavigationBar)
        
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: driverPhotoNavigationBar)
        
        choosePhoto(testFlow: testFlow)
        waitForElementToHasValue(element: testFlow.driverRegistrationHelper.driverPhoto)
        
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: driverPhotoNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931294
    func testCanGoBackFromDriverPhotoToDriverRegistrationScreen_1931294() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        startDriverRegistration(testFlow: testFlow)
        
        let driverPhotoNavigationBar = testFlow.driverRegistrationHelper.driverPhotoNavigationBar
        passedWhenElementAppears(element: driverPhotoNavigationBar)
        
        choosePhoto(testFlow: testFlow)
        waitForElementToAppear(element: driverPhotoNavigationBar)
        driverPhotoNavigationBar.buttons["Drive with RideAustin"].tap()
        
        let registerAsDriverBtn = testFlow.driverRegistrationHelper.registerAsDriverButton
        waitForElementToBeEnable(element: registerAsDriverBtn)
        registerAsDriverBtn.tap()
        
        let licenseAlert = testFlow.driverRegistrationHelper.licenseAlert
        waitForElementToAppear(element: licenseAlert)
        
        let licenseAlertBtn = licenseAlert.buttons["YES"]
        licenseAlertBtn.tap()
        
        waitForElementToAppear(element: driverPhotoNavigationBar)
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverPhotoConfirmation)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931303
    func testDriverPhotoConfirmationAppear_1931303() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        driverPhotoConfirmation(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931302
    func testDriverPhotoConfirmationChooseNo_1931302() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        driverPhotoConfirmation(testFlow: testFlow)
        testFlow.app.buttons["NO"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverPhotoNavigationBar);
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931304
    func testDriverPhotoConfirmationChooseContinue_1931304() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverLicenseScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931305
    func testCannotProceedBeforeSelectingLicensePictureAndExpirationDate_1931305() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverLicenseScreen(testFlow: testFlow)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        let oopsAlert = testFlow.app.alerts["Oops"]
        XCTAssertTrue(oopsAlert.staticTexts["Please select a valid expiration date"].exists)
        oopsAlert.buttons["Dismiss"].tap()
        
        chooseFutureMonth(testFlow: testFlow)
        
        waitForElementToBeHittable(element: nextButton)
        nextButton.tap()
        
        let driverSignupAlert = testFlow.app.alerts["Driver Signup"]
        waitForElementToAppear(element: driverSignupAlert)
        XCTAssertTrue(driverSignupAlert.staticTexts["Please upload a License Photo to continue."].exists)
        driverSignupAlert.buttons["Dismiss"].tap()
        
        choosePhoto(testFlow: testFlow)
        
        nextButton.tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitNavigationBar);
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931309
    func testCanProceedAfterSelectingLicensePictureAndExpirationDate_1931309() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToChaffeurPermitScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931312
    func testCanGoBackFromDriverLicenseToDriverPhoto_1931312() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverLicenseScreen(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.driverLicenseNavigationBar.buttons["Your Driver Photo"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverPhotoNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931308
    func testLicenseExpirationDateShouldBeFutureDate_1931308() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverLicenseScreen(testFlow: testFlow)
        choosePastYear(testFlow: testFlow)
        
        let txtExpirationDateField = testFlow.driverRegistrationHelper.expirationDateTextField
        waitForElementToBeHittable(element: txtExpirationDateField)
        XCTAssertFalse((txtExpirationDateField.value as! String).contains("1993"))
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931306
    func testCanRequestHelpFromDriverLicenseScreen_1931306() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverLicenseScreen(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverLicenseNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931317
    func testChaffeaurScreenShowCorrectTitleAndDescription_1931317() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToChaffeurPermitScreen(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitTitle)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitDescription)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931320
    func testCanContinueWithoutAddingChauffeurPermit_1931320() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToChaffeurPermitScreen(testFlow: testFlow)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        let alert = testFlow.app.alerts["Driver Signup"]
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please upload Chauffeur's Permit photo to continue"].exists)
        alert.buttons["Skip"].tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931325
    func testAvoidBackSideIfFrontChauffeurNotAdded_1931325() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        
        goToChaffeurPermitScreen(testFlow: testFlow)
        
        func skipChaffeur() {
            let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
            nextButton.tap()
            
            let alert = testFlow.app.alerts["Driver Signup"]
            waitForElementToAppear(element: alert)
            XCTAssertTrue(alert.staticTexts["Please upload Chauffeur's Permit photo to continue"].exists)
            alert.buttons["Skip"].tap()
            
            passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
        }
        
        skipChaffeur()
        
        testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar.buttons["Chauffeur's Permit"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitNavigationBar)
        
        choosePhoto(testFlow: testFlow)
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alertMessage = testFlow.app.alerts.staticTexts["Are you sure Chauffeur's Permit is clearly shown in the photo?"]
        passedWhenElementAppears(element: alertMessage)
        testFlow.app.alerts.buttons["YES"].tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitBackSideNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931326
    func testDisplayCorrectPopupOnSubmitChauffeurPermitFrontSide_1931326() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        addChaffeurPermitFrontSide(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931327
    func testDisplayCorrectPopupOnSubmitChauffeurPermitBackSide_1931327() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        addChaffeurPermitBackSide(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931323
    func testCanContinueAfterAddingFrontAndBackChauffeurPermit_1931323() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverVehicleInformation(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931321
    func testCanRequestHelpFromChaffeaurScreen_1931321() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToChaffeurPermitScreen(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931331
    func testAddFrontVehiclePhoto_1931331() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverVehicleInformation(testFlow: testFlow)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .front)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931332
    func testAddBackVehiclePhoto_1931332() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverVehicleInformation(testFlow: testFlow)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .front)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .back)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931333
    func testAddInsideVehiclePhoto_1931333() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverVehicleInformation(testFlow: testFlow)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .front)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .back)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .inside)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931334
    func testAddTrunkVehiclePhoto_1931334() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToVehicleInformationRequirements(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931335
    func testVehicleRequirements_1931335() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToVehicleInformationRequirements(testFlow: testFlow)
        XCTAssertEqual(testFlow.app.tables.cells.count, 4)
        XCTAssertTrue(testFlow.app.tables.cells.textViews["Thank you for choosing to drive with RideAustin. To qualify, drivers are required to be 21 years of age and have vehicles that are:"].exists)
        XCTAssertTrue(testFlow.app.tables.cells.staticTexts["2001 or Newer"].exists)
        XCTAssertTrue(testFlow.app.tables.cells.staticTexts["4 Door"].exists)
        XCTAssertTrue(testFlow.app.tables.cells.staticTexts["Not salvaged or Re-built Vehicles"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931336
    func testVehicleInformationContinueButtonProceedToYearScreen_1931336() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931329
    func testCanRequestHelpFromDriverInformationScreen_1931329() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToDriverVehicleInformation(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931377
    func testCanCancelYearSelection_1931377() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Vehicle Information"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931378
    func testAfterYearSelectionMakeScreenIsOpen_1931378() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931378
    func testUserAbleToChangeYear_1931378() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Year"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.yearNavigationBar)
        goToMakeScreen(testFlow: testFlow, yearIndex: 1)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931381
    func testCanCancelMakeSelection_1931381() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Year"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.yearNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931382
    func testSelectedYearShownInMakeScreen_1931382() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        XCTAssertTrue(testFlow.app.tables.staticTexts["2019"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931383
    func testCanSelectMake_1931383() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931385
    func testCanCancelModelSelection_1931385() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Make"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.makeNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931386
    func testSelectedYearAndMakeShownInModelScreen_1931386() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        XCTAssertTrue(testFlow.app.tables.staticTexts["2019 BMW"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931387
    func testCanSelectModel_1931387() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931389
    func testCanCancelColorSelection_1931389() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Model"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.modelNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931390
    func testSelectedYearMakeAndModelShownInColorScreen_1931390() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        XCTAssertTrue(testFlow.app.tables.staticTexts["2019 BMW X7"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931391
    func testCanSelectColor_1931391() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931393
    func testCannotProceedWithoutEnteringLicensePlate_1931393() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please enter your license plate"].exists)
        alert.buttons["Dismiss"].tap()
        
        let txtLicensePlate = testFlow.driverRegistrationHelper.txtLicensePlate
        waitForElementToBeHittable(element: txtLicensePlate)
        txtLicensePlate.clearAndEnterText(text: "AAJJAA")
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931394
    func testValidateLicensePlate_1931394() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        
        func alertValidation() {
            let alert = testFlow.app.alerts.element
            waitForElementToAppear(element: alert)
            XCTAssertTrue(alert.staticTexts["Please enter your license plate"].exists)
            alert.buttons["Dismiss"].tap()
        }
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        alertValidation()
        
        let txtLicensePlate = testFlow.driverRegistrationHelper.txtLicensePlate
        waitForElementToBeHittable(element: txtLicensePlate)
        txtLicensePlate.clearAndEnterText(text: "        ")
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        alertValidation()
        
        txtLicensePlate.clearAndEnterText(text: "A")
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931395
    func testCanGoBackToColorSelectionFromLicensePlate_1931395() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        testFlow.app.navigationBars.buttons["Color"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.colorNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931396
    func testOnLicensePlateNextButtonMoveToVehicleInformation_1931396() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931399
    func testVehicleInformationScreenShowCorrectMessage_1931399() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        XCTAssertTrue(testFlow.driverRegistrationHelper.newCarMessage.exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931400
    func testPressingNextButtonFromVehicleInformationMoveToInsuranceScreen() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931415
    func testCannotProceedInsuranceScreenWithoutAddingPhotoAndExpirationDate_1931415() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        let alert = testFlow.app.alerts["Oops"]
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please select a valid expiration date"].exists)
        alert.buttons["Dismiss"].tap()
        
        goToFCRADisclosureScreen(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931425
    func testInsuranceExpirationDateShouldBeGreaterThanCurrentDate_1931425() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        choosePhoto(testFlow: testFlow)
        choosePastYear(testFlow: testFlow)
        
        let txtExpirationDateField = testFlow.driverRegistrationHelper.expirationDateTextField
        waitForElementToBeHittable(element: txtExpirationDateField)
        XCTAssertFalse((txtExpirationDateField.value as! String).contains("1993"))
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931416
    func testCanRequestHelpFromInsuranceScreen_1931416() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.insuranceNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931417
    func testCanGoBackFromInsuranceScreen_1931417() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.insuranceNavigationBar.buttons["Vehicle Information"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931422
    func testCanCancelInsurancePhotoSelection_1931422() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        
        let takePhotoButton = testFlow.driverRegistrationHelper.takePhotoButton
        takePhotoButton.tap()
        
        let photoSourceSheet = testFlow.driverRegistrationHelper.cameraSheet
        passedWhenElementAppears(element: photoSourceSheet)
        photoSourceSheet.buttons["cancel"].tap()
        
        waitForElementToBeHittable(element: takePhotoButton)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931435
    func testFirstNameValidation_1931435() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931436
    func testMiddleNameValidation_1931436() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931437
    func testLastNameValidation_1931437() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931439
    func testDateOfBirthValidation_1931439() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931440
    func testSSNValidation_1931440() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931443
    func testZipCodeValidation_1931443() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931444
    func testDriverLicenseValidation_1931444() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931445
    func testStateCodeValidation_1931445() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931450
    func testAddressIsMandatory_1931450() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931446
    func testCannotProceedWithoutAckReceipt_1931446 () {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931433
    func testFCRADisclosureTitleAndDescription_1931433() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        
        XCTAssertEqual(testFlow.app.staticTexts["lawTitle"].label, "RideAustin (the \"Company\") has engaged Checkr, Inc. to obtain a consumer report. Checkr Inc. will provide a background investigation as a pre-condition of your engagement with the Company and in compliance with federal and state laws.\n\nIf you have any questions related to the screening process, please contact us at applicant.checkr.com.")
        XCTAssertEqual(testFlow.app.staticTexts["summaryTitle"].label, "Summary of Your Rights Under the Fair Credit Reporting Act")
        XCTAssertEqual(testFlow.app.staticTexts["summaryDetail"].label.trimmingCharacters(in: .whitespacesAndNewlines), "The FCRA is a complex piece of legislation and contains numerous provisions not discussed on this page. Below are several important features of how the FCRA is designed to help consumers (for the complete text, visit the Federal Trade Commission). The FCRA protects you by requiring consumer reporting agencies.")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931447
    func testCanGoBackFromFCRADisclosureScreen_1931447() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar.buttons["Insurance"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.insuranceNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931434
    func testCanRequestHelpFromFCRADisclouseScreen() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931427
    func testFCRADisclosureIITitleAndDescription_1931427() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureIITitle.label, "Disclosure regarding background check investigation")
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureIIFirstLawSummary.label, "RideAustin (“the Company”) may obtain information about you from a third party consumer reporting agency for contract purposes.  Thus, you may be the subject of a “consumer report” and/or an “investigative consumer report” which may include information about your character, general reputation, personal characteristics, and/or mode of living, and which can involve personal interviews with sources such as your neighbors, friends, or associates.  These reports may contain information regarding your criminal history, social security verification, motor vehicle records (“driving records”), verification of your education or employment history, or other background checks.")
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureIISecondLawSummary.label, "You have the right, upon written request made within a reasonable time, to request whether a consumer report has been run about you, and disclosure of the nature and scope of any investigative consumer report and to request a copy of your report.  Please be advised that the nature and scope of the most common form of investigative consumer report is an employment history or verification.  These searches will be conducted by Checkr, Inc., 2505 Mariposa St. San Francisco, CA 94110 | 844-824-3247 | applicant.checkr.com.  The scope of this disclosure is all-encompassing, however, allowing the Company to obtain from any outside organization all manner of consumer reports throughout the course of your contract to the extent permitted by law.")
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureIICheckboxDescription.label, "I acknowledge receipt of the Disclosure Regarding Background Investigation and certify that I have read and understand this document.")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931429
    func testCannotProceedWithoutAckFCRADisclosureII_1931429() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please acknowledge receipt of the Disclosure Regarding Background Investigation and certify that You have read and understand this document."].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931430
    func testCanGoBackFromFCRADisclosureIIScreen_1931430() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar.buttons["Back"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931431
    func testAfterAcceptingAckCanMoveToDisclosureIIIScreen_1931431() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931428
    func testCanRequestHelpFromFCRADisclosureIIScreen_1931428() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931451
    func testFCRADisclosureIIITitleAndDescription_1931451() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureAckAndAuthTitle.label, "Acknowledgment and Authorization for background check")
        XCTAssertEqual(testFlow.driverRegistrationHelper.fcraDisclosureAckAndAuthSummary.label, "I acknowledge receipt of the separate document entitled DISCLOSURE REGARDING BACKGROUND INVESTIGATION and A SUMMARY OF YOUR RIGHTS UNDER THE FAIR CREDIT REPORTING ACT and certify that I have read and understand both of those documents.  I hereby authorize the obtaining of “consumer reports” and/or “investigative consumer reports” by the Company at any time after receipt of this authorization and throughout my contract, if applicable.  To this end, I hereby authorize, without reservation, any law enforcement agency, administrator, state or federal agency, institution, school or university (public or private), information service bureau, employer, or insurance company to furnish any and all background information requested by Checkr, Inc., 2505 Mariposa St. Floor 2, San Francisco, CA 94110 | 844-824-3247 | applicant.checkr.com.  I agree that an electronic copy of this Authorization shall be as valid as the original.")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931452
    func testCanRequestHelpFromFCRADisclosureIIIScreen_1931452() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931453
    func testCannotContinueWithouEnteringFirstAndLastNameToSignTheDisclosure_1931453() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please digitally sign with Your full name as entered previously, including first name, middle names and last name."].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931454
    func testCannotContinueIfElectronicSignatureDoesntCorrespondToFirstAndLastName_1931454() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.fcraDisclosureElectronicSignatureTextField.clearAndEnterText(text: "Mark Anthony")
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please digitally sign with Your full name as entered previously, including first name, middle names and last name."].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931456
    func testNextButtonProceedsToTermsAndConditionScreen_1931456() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931455
    func testCanGoBackFromFCRADisclosureIIIScreen_1931455() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.termAndConditionNavigationBar.buttons["Back"].tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931458
    func testTermAndConditionTitleAndText_1931458() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
        
        XCTAssertEqual(testFlow.driverRegistrationHelper.termAndConditionTitle.label, "Review and approve the Driver terms and conditions")
        XCTAssertEqual(testFlow.driverRegistrationHelper.termAndConditionContent.value as! String, "Terms and conditions response")
        XCTAssertEqual(testFlow.driverRegistrationHelper.checkBoxTermAndConditionDescription.label, "I AGREE AND ACKNOWLEDGE")
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931459
    func testCannotContinueTermAndConditionWithoutAck_1931459() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
        
        testFlow.driverRegistrationHelper.continueButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Please agree to continue"].exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931461
    func testFinalizeRegisteringProccessAfterAckTermAndCondition_1931461() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
        ackTermAndCondition(testFlow: testFlow)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931460
    func testCanRequestHelpFromTermAndConditionScreen_1931460() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        goToYearScreen(testFlow: testFlow)
        goToMakeScreen(testFlow: testFlow)
        goToModelScreen(testFlow: testFlow)
        goToColorScreen(testFlow: testFlow)
        goToLicensePlateScreen(testFlow: testFlow)
        goToVehicleInformationRegistration(testFlow: testFlow)
        goToInsuranceScreen(testFlow: testFlow)
        goToFCRADisclosureScreen(testFlow: testFlow)
        addFirstNameFCRADisclosure(testFlow: testFlow)
        addMiddleNameFCRADisclosure(testFlow: testFlow)
        addLastNameFCRADisclosure(testFlow: testFlow)
        chooseDateOfBirth(testFlow: testFlow)
        addSSNFCRADisclosure(testFlow: testFlow)
        addZipCodeFCRADisclosure(testFlow: testFlow)
        addDriverLicenseFCRADisclosure(testFlow: testFlow)
        addStateCodeFCRADisclosure(testFlow: testFlow)
        addAddressFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosure(testFlow: testFlow)
        ackFCRADisclosureII(testFlow: testFlow)
        addElectronicSignature(testFlow: testFlow)
        sendSupportMessage(testFlow: testFlow)
    }
    
    //MARK: Helpers
    func startDriverRegistration(testFlow: RAUITestFlow, buttonName: String = "YES") {
        testFlow.goToDriverRegistration()
        let registerAsDriverBtn = testFlow.driverRegistrationHelper.registerAsDriverButton
        waitForElementToBeEnable(element: registerAsDriverBtn)
        registerAsDriverBtn.tap()
        
        let licenseAlert = testFlow.driverRegistrationHelper.licenseAlert
        waitForElementToAppear(element: licenseAlert)
        
        let alertBtn = licenseAlert.buttons[buttonName]
        alertBtn.tap()
    }
    
    func sendSupportMessage(testFlow: RAUITestFlow, message: String = "Sample") {
        let helpBar = testFlow.contactSupportVCInspector.helpBar;
        helpBar.tap()
        
        let contactSupport = testFlow.contactSupportVCInspector.contactSupportNavigationBar
        passedWhenElementAppears(element: contactSupport)
        
        let supportMessageTextView = testFlow.contactSupportVCInspector.contactSupportMessageTextView
        supportMessageTextView.clearAndEnterText(text: "Sample")
        
        let sendMesageButton = contactSupport.buttons["Send"]
        sendMesageButton.tap()
    }
    
    func choosePhoto(testFlow: RAUITestFlow) {
        let takePhotoButton = testFlow.driverRegistrationHelper.takePhotoButton
        waitForElementToBeHittable(element: takePhotoButton)
        takePhotoButton.tap()
        
        let photoSourceSheet = testFlow.driverRegistrationHelper.cameraSheet
        passedWhenElementAppears(element: photoSourceSheet)
        XCTAssertTrue(photoSourceSheet.staticTexts["From where do you want to take the picture?"].exists)
        XCTAssertTrue(photoSourceSheet.buttons["Camera"].exists)
        
        let btnPhotoGallery = photoSourceSheet.buttons["Choose from library"]
        btnPhotoGallery.tap()
        testFlow.app.tap()
        
        //XCTAssert(testFlow.app.navigationBars["Photos"].exists, "Check Photos library permissions")
        testFlow.app.tables.cells.element(boundBy: 1).tap()
        
        let photoCollectionView = testFlow.app.collectionViews["PhotosGridView"]
        XCTAssertTrue(photoCollectionView.exists)
        
        photoCollectionView.cells.element(boundBy: 0).tap()
        
        let window = testFlow.app.windows.element(boundBy: 0)
        let coordinateNormalized = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinateScreen = coordinateNormalized.withOffset(CGVector(dx: window.frame.width - 20, dy: window.frame.height - 20))
        coordinateScreen.tap()
    }
    
    func choosePastYear(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.expirationDateTextField.tap()
        let datePicker = testFlow.app.datePickers.element
        waitForElementToAppear(element: datePicker)
        datePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1993")
        testFlow.app.tap()
        sleep(3)
    }
    
    func chooseFutureMonth(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.expirationDateTextField.tap()
        let datePicker = testFlow.app.datePickers.element
        waitForElementToAppear(element: datePicker)
        datePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "December")
        testFlow.app.tap()
        sleep(3)
    }
    
    func driverPhotoConfirmation(testFlow: RAUITestFlow) {
        startDriverRegistration(testFlow: testFlow)
        
        let driverPhotoNavigationBar = testFlow.driverRegistrationHelper.driverPhotoNavigationBar
        passedWhenElementAppears(element: driverPhotoNavigationBar)
        
        choosePhoto(testFlow: testFlow)
        waitForElementToAppear(element: driverPhotoNavigationBar)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverPhotoConfirmation)
    }
    
    func goToDriverLicenseScreen(testFlow: RAUITestFlow) {
        driverPhotoConfirmation(testFlow: testFlow)
        testFlow.app.buttons["YES"].tap()
        waitForElementToAppear(element: testFlow.driverRegistrationHelper.driverLicenseNavigationBar);
    }
    
    func goToChaffeurPermitScreen(testFlow: RAUITestFlow) {
        goToDriverLicenseScreen(testFlow: testFlow)
        chooseFutureMonth(testFlow: testFlow)
        choosePhoto(testFlow: testFlow)
        
        let navigationBarNextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        waitForElementToBeHittable(element: navigationBarNextButton)
        navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.chauffeurPermitNavigationBar);
    }
    
    func addChaffeurPermitFrontSide(testFlow: RAUITestFlow) {
        goToChaffeurPermitScreen(testFlow: testFlow)
        choosePhoto(testFlow: testFlow)
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alertMessage = testFlow.app.alerts.staticTexts["Are you sure Chauffeur's Permit is clearly shown in the photo?"]
        passedWhenElementAppears(element: alertMessage)
        testFlow.app.alerts.buttons["YES"].tap()
    }
    
    func addChaffeurPermitBackSide(testFlow: RAUITestFlow) {
        addChaffeurPermitFrontSide(testFlow: testFlow)
        waitForElementToAppear(element: testFlow.driverRegistrationHelper.chauffeurPermitBackSideNavigationBar)
        chooseFutureMonth(testFlow: testFlow)
        choosePhoto(testFlow: testFlow)
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        
        let alertMessage = testFlow.app.alerts.staticTexts["Are you sure Chauffeur's Permit Backside is clearly shown in the photo?"]
        passedWhenElementAppears(element: alertMessage)
        testFlow.app.alerts.buttons["YES"].tap()
    }
    
    func goToDriverVehicleInformation(testFlow: RAUITestFlow) {
        addChaffeurPermitBackSide(testFlow: testFlow)
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    enum VehiclePhotoType {
        case front, back, inside, trunk
    }
    
    func chooseVehiclePhoto(testFlow: RAUITestFlow, vehiclePhotoType type: VehiclePhotoType) {
        choosePhoto(testFlow: testFlow)
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        alert.buttons["YES"].tap()
        
        let element:XCUIElement
        switch type {
        case .front:
            element = testFlow.app.textViews["Back right angle showing plate"]
        case .back:
            element = testFlow.app.textViews["Inside photo showing the entire back seat"]
        case .inside:
            element = testFlow.app.textViews["Open trunk, full view"]
        case .trunk:
            element = testFlow.driverRegistrationHelper.continueButton
        }
        
        passedWhenElementAppears(element: element)
    }
    
    func goToVehicleInformationRequirements(testFlow: RAUITestFlow) {
        goToDriverVehicleInformation(testFlow: testFlow)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .front)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .back)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .inside)
        chooseVehiclePhoto(testFlow: testFlow, vehiclePhotoType: .trunk)
    }
    
    func goToYearScreen(testFlow: RAUITestFlow) {
        goToVehicleInformationRequirements(testFlow: testFlow)
        testFlow.driverRegistrationHelper.continueButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.yearNavigationBar)
    }
    
    func goToMakeScreen(testFlow: RAUITestFlow, yearIndex: UInt = 0) {
        testFlow.app.tables.cells.element(boundBy: Int(yearIndex)).tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.makeNavigationBar)
    }
    
    func goToRegistrationSticker(testFlow: RAUITestFlow, yearIndex: UInt = 0) {
        testFlow.app.tables.cells.element(boundBy: Int(yearIndex)).tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.registrationSticker)
    }
    
    func goToModelScreen(testFlow: RAUITestFlow, makeIndex: UInt = 0) {
        testFlow.app.tables.cells.element(boundBy: Int(makeIndex)).tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.modelNavigationBar)
    }
    
    func goToColorScreen(testFlow: RAUITestFlow, modelIndex: UInt = 0) {
        testFlow.app.tables.cells.element(boundBy: Int(modelIndex)).tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.colorNavigationBar)
    }
    
    func goToLicensePlateScreen(testFlow: RAUITestFlow, colorIndex: UInt = 0) {
        testFlow.app.tables.cells.element(boundBy: Int(colorIndex)).tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.licensePlateNavigationBar)
    }
    
    func goToVehicleInformationRegistration(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.txtLicensePlate.clearAndEnterText(text: "AAJJAA")
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.driverVehicleInformationNavigationBar)
    }
    
    func goToInsuranceScreen(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.insuranceNavigationBar)
    }
    
    func goToFCRADisclosureScreen(testFlow: RAUITestFlow) {
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.insuranceNavigationBar)
        choosePhoto(testFlow: testFlow)
        chooseFutureMonth(testFlow: testFlow)
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        waitForElementToBeHittable(element: nextButton)
        nextButton.tap()
        
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar)
    }
    
    func dismissValidationAlert(testFlow:RAUITestFlow, message: String, shouldExist: Bool = true) {
        let alert = testFlow.app.alerts.firstMatch
        waitForElementToAppear(element: alert)
        XCTAssertEqual(alert.staticTexts[message].exists, shouldExist)
        alert.buttons["Dismiss"].tap()
    }
    
    func addFirstNameFCRADisclosure(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.fcraDisclosureFirstNameTextField.clearAndEnterText(text: "")
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: "First name must be at least 2 characters")
        
        testFlow.driverRegistrationHelper.fcraDisclosureFirstNameTextField.clearAndEnterText(text: "J")
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: "First name must be at least 2 characters")
        
        testFlow.driverRegistrationHelper.fcraDisclosureFirstNameTextField.clearAndEnterText(text: "Jo")
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: "First name must be at least 2 characters", shouldExist: false)
    }
    
    func addMiddleNameFCRADisclosure(testFlow: RAUITestFlow) {
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        let validationMessage = "Middle name must be at least 2 characters or confirm you do not have a middle name"
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureMiddleNameTextField.clearAndEnterText(text: "J")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureMiddleNameTextField.clearAndEnterText(text: "Jo")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
        
        testFlow.driverRegistrationHelper.fcraDisclosureChecboxMiddleName.tap()
        XCTAssertNotEqual(testFlow.driverRegistrationHelper.fcraDisclosureMiddleNameTextField.value as! String, "Jo")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
        
        testFlow.driverRegistrationHelper.fcraDisclosureChecboxMiddleName.tap()
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureChecboxMiddleName.tap()
    }
    
    func addLastNameFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Last name must be at least 2 characters"
        
        testFlow.driverRegistrationHelper.fcraDisclosureLastNameTextField.clearAndEnterText(text: "")
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureLastNameTextField.clearAndEnterText(text: "J")
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureLastNameTextField.clearAndEnterText(text: "Jo")
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func chooseDateOfBirth(testFlow: RAUITestFlow) {
        let validationMessage = "Please enter a valid Birth Date (MM/DD/YYYY)"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureDateOfBirthTextField.tap()
        
        let datePicker = testFlow.app.datePickers.element
        waitForElementToAppear(element: datePicker)
        datePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1993")
        testFlow.app.tap()
        sleep(3)
        
        waitForElementToBeHittable(element: nextButton)
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func addSSNFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Please enter valid SSN number i.e 9 digits number"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        let txtSSN = testFlow.driverRegistrationHelper.fcraDisclosureSSNTextField
        txtSSN.clearAndEnterText(text: "AAAAAAAAA")
        
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtSSN.clearAndEnterText(text: "123456")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtSSN.clearAndEnterText(text: "123456789")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func addZipCodeFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Please enter a valid Zip code"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        let txtZipCode = testFlow.driverRegistrationHelper.fcraDisclosureZipCodeTextField
        txtZipCode.clearAndEnterText(text: "000000")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtZipCode.clearAndEnterText(text: "ABCDEF")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtZipCode.clearAndEnterText(text: "78701")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func addDriverLicenseFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Please enter a valid Driver's License Number"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        let txtDriverLicense = testFlow.driverRegistrationHelper.fcraDisclosureDriverLicenseTextField
        txtDriverLicense.clearAndEnterText(text: "123")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtDriverLicense.clearAndEnterText(text: "1234567")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
        
        txtDriverLicense.clearAndEnterText(text: "12345678")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func addStateCodeFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Please enter a valid 2 letter State code"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        let txtStateCode = testFlow.driverRegistrationHelper.fcraDisclosureStateCodeTextField
        txtStateCode.clearAndEnterText(text: "12")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtStateCode.clearAndEnterText(text: "MM")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtStateCode.clearAndEnterText(text: "MA")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func addAddressFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "Address must be at least 2 characters"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: "Please enter the address to continue")
        
        let txtAddress = testFlow.driverRegistrationHelper.fcraDisclosureAddressTextField
        txtAddress.clearAndEnterText(text: "M")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        txtAddress.clearAndEnterText(text: "Jollyville, Austin, TX")
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage, shouldExist: false)
    }
    
    func ackFCRADisclosure(testFlow: RAUITestFlow) {
        let validationMessage = "You must acknowledge receipt of the Summary of Your Rights Under the Fair Credit Reporting Act"
        
        let nextButton = testFlow.driverRegistrationHelper.navigationBarNextButton
        nextButton.tap()
        dismissValidationAlert(testFlow: testFlow, message: validationMessage)
        
        testFlow.driverRegistrationHelper.fcraDisclosureCheckBoxAckReceipt.tap()
        nextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar)
    }
    
    func ackFCRADisclosureII(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.fcraDisclosureIICheckBox.tap()
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.fcraDisclosureNavigationBar)
    }
    
    func addElectronicSignature(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.fcraDisclosureElectronicSignatureTextField.clearAndEnterText(text: "Jo Jo")
        testFlow.driverRegistrationHelper.navigationBarNextButton.tap()
        passedWhenElementAppears(element: testFlow.driverRegistrationHelper.termAndConditionNavigationBar)
    }
    
    func ackTermAndCondition(testFlow: RAUITestFlow) {
        testFlow.driverRegistrationHelper.checkBoxTermAndCondition.tap()
        testFlow.driverRegistrationHelper.continueButton.tap()
        
        let alert = testFlow.app.alerts.element
        waitForElementToAppear(element: alert)
        XCTAssertTrue(alert.staticTexts["Thank you for your application! We will reach out to you soon regarding next steps."].exists)
        alert.buttons["OK"].tap()
        
        passedWhenElementAppears(element: testFlow.mapHelper.setPickUpButton)
    }
    
}
