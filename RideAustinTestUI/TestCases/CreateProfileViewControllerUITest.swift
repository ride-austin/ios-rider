//
//  CreateProfileViewControllerUITest.swift
//  Ride
//
//  Created by Roberto Abreu on 5/16/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class CreateProfileViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUIElements() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        let app = testFlow.app
        
        testFlow.doRegistrationFlow()
        
        let createProfileNavigationBar = app.navigationBars["CREATE A PROFILE"]
        waitForElementToAppear(element: createProfileNavigationBar, timeout: 15)
        XCTAssertTrue(app.images["imgProfilePicture"].exists)
        XCTAssertTrue(app.textFields["First Name"].exists)
        XCTAssertTrue(app.textFields["Last Name"].exists)
        XCTAssertTrue(app.staticTexts["By creating an Ride Austin account, you agree to the"].exists)
        
        let btnNext = createProfileNavigationBar.buttons["NEXT"]
        XCTAssertTrue(btnNext.exists && btnNext.isEnabled)
        
        let btnTermAndCondition = app.buttons["Terms & Conditions and Privacy Policy"]
        XCTAssertTrue(btnTermAndCondition.exists && btnTermAndCondition.isEnabled)
    }
    
    func assertErrorAlert(_ alert:XCUIElement, message:String) {
        passedWhenElementAppears(element: alert)
        XCTAssertTrue(alert.staticTexts[message].exists)
        alert.buttons["Dismiss"].tap()
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931477
    func testFirstNameAndLastNameValidations_1931477() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        let app = testFlow.app
        
        testFlow.doRegistrationFlow()
        
        let txtFirstName = app.textFields["First Name"]
        let txtLastName = app.textFields["Last Name"]
        let btnNext = app.buttons["NEXT"]
        let alert = app.alerts["Oops"]
        
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter your firstname.")
        
        txtFirstName.clearAndEnterText(text: "#NameTest")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid first name with english letters only.")
        
        txtFirstName.clearAndEnterText(text: "%&%&%&%&^")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid first name with english letters only.")
        
        txtFirstName.clearAndEnterText(text: "K")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid first name with minimum two letters.")
        
        txtFirstName.clearAndEnterText(text: "Karl")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter your lastname.")
        
        txtLastName.clearAndEnterText(text: "#NameTest")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid last name with english letters only.")
        
        txtLastName.clearAndEnterText(text: "%&%&%&%&^")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid last name with english letters only.")
        
        txtLastName.clearAndEnterText(text: "S")
        btnNext.tap()
        assertErrorAlert(alert, message: "Please enter a valid last name with minimum two letters.")
        
        txtLastName.clearAndEnterText(text: "Sanz")
        btnNext.tap()
        
        passedWhenElementAppears(element: app.navigationBars["Round up"])
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931480
    func testTermAndConditionAustin_1931480() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        let app = testFlow.app
        
        testFlow.doRegistrationFlow()
        
        app.buttons["Terms & Conditions and Privacy Policy"].tap()
        
        XCTAssertTrue(app.navigationBars["Terms & Conditions"].exists)
        XCTAssertTrue(app.webViews.element.exists)
        
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931480
    // Same case as testTermAndConditionAustin
    func testTermAndConditionHouston() {
        let testFlow = RAUITestFlow(self, launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefaultHouston])
        testFlow.launchApp()
        
        let app = testFlow.app
        
        testFlow.doRegistrationFlow()
        
        XCTAssertTrue(app.staticTexts["By creating an Ride Houston account, you agree to the"].exists)
        app.buttons["Terms & Conditions and Privacy Policy"].tap()
        
        XCTAssertTrue(app.navigationBars["Terms & Conditions"].exists)
        XCTAssertTrue(app.webViews.element.exists)
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931478
    func DISABLED_testAddPhotoFromLibrary_1931478() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchApp()
        let app = testFlow.app
        
        addUIInterruptionMonitor(withDescription: "Photos permission alert") { (alert:XCUIElement) -> Bool in
            if alert.buttons.element(boundBy: 1).exists {
                alert.buttons.element(boundBy: 1).tap()
                return true
            }
            return false
        }
        
        testFlow.doRegistrationFlow()
        
        let imgProfile = app.images["imgProfilePicture"]
        
        let btnPicturePicker = app.buttons["picturePicker"]
        btnPicturePicker.tap()
        
        let photoSourceSheet = app.sheets["Source"]
        passedWhenElementAppears(element: photoSourceSheet)
        XCTAssertTrue(photoSourceSheet.staticTexts["From where do you want to take the picture?"].exists)
        XCTAssertTrue(photoSourceSheet.buttons["Camera"].exists)
        
        let btnPhotoGallery = photoSourceSheet.buttons["Choose from library"]
        btnPhotoGallery.tap()
        app.tap() //need to interact with the app again for the UIInterruptionMonitor
        
        XCTAssert(app.navigationBars["Photos"].exists, "Check Photos library permissions")
        app.tables.cells.element(boundBy: 0).tap()
        
        let photoCollectionView = app.collectionViews["PhotosGridView"]
        XCTAssertTrue(photoCollectionView.exists)
        
        photoCollectionView.cells.element(boundBy: 0).tap()

        let window = app.windows.element(boundBy: 0)
        let coordinateNormalized = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinateScreen = coordinateNormalized.withOffset(CGVector(dx: window.frame.width - 20, dy: window.frame.height - 20))
        coordinateScreen.tap()
        
        waitForElementToHasValue(element: imgProfile, timeout: 15)
        
        app.textFields["First Name"].clearAndEnterText(text: "Sample")
        app.textFields["Last Name"].clearAndEnterText(text: "Sample")
        app.buttons["NEXT"].tap()
        
        passedWhenElementAppears(element: app.navigationBars["Round up"])
    }
    
}
