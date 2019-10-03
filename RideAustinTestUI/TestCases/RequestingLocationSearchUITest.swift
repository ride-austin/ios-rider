//
//  RequestingLocationSearchUITest.swift
//  Ride
//
//  Created by Marcos Alba on 5/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

//Test case 5.1.3. Location Search: https://issue-tracker.devfactory.com/browse/RA-10157
class RequestingLocationSearchUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //A. Search: Airport and other Austin locations comes up at first place according to the current city: https://issue-tracker.devfactory.com/browse/RA-10246
    // https://testrail.devfactory.com/index.php?/cases/view/1931527
    //Use RideAustinTest Automation target
    func testAustinAirportInFirstPlace_1931527() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        //Pickup
        testFlow.goToAddress("Air")
        XCTAssertTrue(testFlow.mapHelper.pickUpTextField.label.contains("Austin-Bergstrom International Airport"))
        
        //Destination
        testFlow.setDestinationAt("Air")
        XCTAssertTrue(testFlow.mapHelper.destinationTextField.label.contains("Austin-Bergstrom International Airport"))
    }
    
    // https://testrail.devfactory.com/index.php?/cases/view/1931527
    //Use RideHoustonTest Automation target
    func testHoustonAirportInFirstPlace() {
        let testFlow = RAUITestFlow(self,launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration,XCUIApplication.XCUIAppArgumentConfigurationDefaultHouston])
        testFlow.launchAppToMapInInitialState()
        
        //Pickup
        testFlow.goToAddress("Air")
        XCTAssertTrue(testFlow.mapHelper.pickUpTextField.label.contains("Hobby Airport"))
        
        //Destination
        testFlow.setDestinationAt("Air")
        XCTAssertTrue(testFlow.mapHelper.destinationTextField.label.contains("Hobby Airport"))
    }
    
    //B. Recent Places: Selecting a place from the recent places moves the pin to the correct location. https://issue-tracker.devfactory.com/browse/RA-10374
    // https://testrail.devfactory.com/index.php?/cases/view/1931528
    func testRecentPlacesPickUpPin_1931528(){
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        testFlow.setPickUpAt("Hut's")
       
        let requestRideView = testFlow.mapHelper.requestView
        waitForElementToAppear(element: requestRideView)
        testFlow.tapCancelRequest()
        
        let pickUpButton = testFlow.mapHelper.setPickUpButton
        waitForElementToAppear(element: pickUpButton)
        
        testFlow.showPickerAddressFromPickUp()
        XCTAssertTrue(testFlow.pickerAddressVCInspector.recentPlaceCells.count > 0)
        
        let lastRecentPlaceSelected = testFlow.pickerAddressVCInspector.recentPlaceCells.filter { $0.label.contains("Hut's") }.first
        lastRecentPlaceSelected?.tap()
        waitForElementToAppear(element: pickUpButton)
        
        let destinationText = testFlow.app.otherElements["Hut's Hamburgers"]
        waitForElementToAppear(element: destinationText)
        
        testFlow.mapHelper.assertMapViewInState(.Initial)
    }
    
    // C: Recent Places II: New user, clicking pick up or destination no recent places is shown https://issue-tracker.devfactory.com/browse/RA-10403
    // Using this account: anewuser@xo.com / test123 -- IMPORTANT: do not press pickup button neither search for any location :)
    // https://testrail.devfactory.com/index.php?/cases/view/1931530
    func testRecentPlacesInNewUser_1931530() {
        let testFlow = RAUITestFlow(self,launchArguments: [XCUIApplication.XCUIAppArgumentConfigurationDefault,"MAP_LOGIN_NEW"])
        testFlow.launchApp()
        testFlow.signInNew()
        
        testFlow.mapHelper.assertMapViewInState(.Initial)
        testFlow.mapHelper.closeRoundUpAlertIfNeeded()
        
        testFlow.showPickerAddressFromPickUp()
        XCTAssertEqual(testFlow.pickerAddressVCInspector.recentPlaceCells.count, 0)
    }
    
    // D: Recent Places III: Search a first place on the pick up text field, it should be available as a recent place on the destination. https://issue-tracker.devfactory.com/browse/RA-10404
    // https://testrail.devfactory.com/index.php?/cases/view/1931531
    func testRecentPlaceFromPickUpAvailableAlsoInDestinationField_1931531() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        testFlow.setPickUpAt("Hut's")
        testFlow.showPickerAddressFromDestination()
        
        let firstRecentPlace = testFlow.pickerAddressVCInspector.recentPlaceCells.first
        XCTAssertTrue(firstRecentPlace!.label.contains("Hut's"))
    }
    
    // E: Recent Places IV: Search new places, they should be added on top of the recent places list. https://issue-tracker.devfactory.com/browse/RA-10405
    // F. Recent Places V: Show a maximum of five recent places. https://issue-tracker.devfactory.com/browse/RA-10406
    // https://testrail.devfactory.com/index.php?/cases/view/1931533
    func testMaximum10RecentPlaces_1931533() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        let recentPlaces = ["Air", "Hut's", "Lavaca", "Hyde", "Congress", "Red",
                            "Oak", "Crest", "Rosedale", "Bowie", "Jollyville"]
        
        for (index, place) in recentPlaces.enumerated() {
            let previousPlace:String? = index > 0 ? recentPlaces[index - 1] : nil
            selectRecentPlaceWithTestFlow(testFlow, address: place, previousAddress: previousPlace)
        }
    }
    
    // G. Recent Places VI: A single location is not repeated on the list of recent places. https://issue-tracker.devfactory.com/browse/RA-10407
    // https://testrail.devfactory.com/index.php?/cases/view/1931534
    func testRecentPlacesAreNotRepeated_1931534() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        selectRecentPlaceWithTestFlow(testFlow, address: "Air")
        selectRecentPlaceWithTestFlow(testFlow, address: "Air")
        selectRecentPlaceWithTestFlow(testFlow, address: "Air")
        
        testFlow.showPickerAddressFromPickUp()
        let cells = testFlow.pickerAddressVCInspector.recentPlaceCells.filter { $0.label.contains("Austin-Bergstrom") }
        XCTAssertEqual(cells.count, 1)
    }
    
    //I. Recent Places: VIII: Recent places are unique to different users. https://issue-tracker.devfactory.com/browse/RA-10409
    // https://testrail.devfactory.com/index.php?/cases/view/1931536
    func testRecentPlacesAreUniquePerUser_1931536()  {
        let testFlow = RAUITestFlow(self,launchArguments: [XCUIApplication.XCUIAppArgumentConfiguration, XCUIApplication.XCUIAppArgumentConfigurationRealAuth])
        
        //Login User 1
        testFlow.launchAppToMapInInitialState(withUser: TestUser3)
        testFlow.tapNoIfExists()
        
        let recentPlacesUser1 = ["Air", "Hut's", "Lavaca", "Hyde", "Congress", "Red",
                            "Oak", "Crest", "Rosedale", "Bowie", "Jollyville"]
        
        for (index, place) in recentPlacesUser1.enumerated() {
            let previousPlace:String? = index > 0 ? recentPlacesUser1[index - 1] : nil
            selectRecentPlaceWithTestFlow(testFlow, address: place, previousAddress: previousPlace)
        }
        
        testFlow.signOut()
        
        //Login User 2
        testFlow.signIn(TestUser2)
        sleep(2)
        testFlow.tapNoIfExists()
        
        let recentPlacesUser2 = ["Hut's", "Lavaca", "Oak", "Bowie", "Congress", "Air",
                                 "Red", "Crest", "Rosedale", "Jollyville", "Hyde"]
        
        for (index, place) in recentPlacesUser2.enumerated() {
            let previousPlace:String? = index > 0 ? recentPlacesUser2[index - 1] : nil
            selectRecentPlaceWithTestFlow(testFlow, address: place, previousAddress: previousPlace)
        }
        
        testFlow.showPickerAddressFromPickUp()
        let user2RecentPlaces:[String] = testFlow.pickerAddressVCInspector.recentPlaceCells.map { $0.label }
        testFlow.app.navigationBars.element(boundBy: 0).buttons["Back"].tap()
        
        testFlow.signOut()
        
        //Login User 1
        testFlow.signIn(TestUser3)
        sleep(2)
        testFlow.tapNoIfExists()

        testFlow.showPickerAddressFromPickUp()
        let user1RecentPlaces:[String] = testFlow.pickerAddressVCInspector.recentPlaceCells.map { $0.label }
        testFlow.app.navigationBars.element(boundBy: 0).buttons["Back"].tap()
        
        XCTAssertNotEqual(user1RecentPlaces, user2RecentPlaces)
    }
    
    // J. Recent Places IX: Recent places still available after logging out and logging back in. https://issue-tracker.devfactory.com/browse/RA-10410
    // https://testrail.devfactory.com/index.php?/cases/view/1931537
    func testRecentPlacesAreAvilableLoggingOutAndLoggingBackIn_1931537() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()

        let recentPlaces = ["Air", "Hut's", "Lavaca", "Hyde", "Congress", "Red",
                            "Oak", "Crest", "Rosedale", "Bowie"]
        
        for (index, place) in recentPlaces.enumerated() {
            let previousPlace:String? = index > 0 ? recentPlaces[index - 1] : nil
            selectRecentPlaceWithTestFlow(testFlow, address: place, previousAddress: previousPlace)
        }
        
        testFlow.showPickerAddressFromPickUp()
        let userRecentPlaces:[String] = testFlow.pickerAddressVCInspector.recentPlaceCells.map { $0.label }
        testFlow.app.navigationBars.element(boundBy: 0).buttons["Back"].tap()
        
        testFlow.signOut()
        testFlow.goToMapInInitialState()
        
        testFlow.showPickerAddressFromPickUp()
        let userRecentPlacesAfterSignout:[String] = testFlow.pickerAddressVCInspector.recentPlaceCells.map { $0.label }
        
        XCTAssertEqual(userRecentPlaces, userRecentPlacesAfterSignout)
    }
    
    //MARK: Helpers
    
    func selectRecentPlaceWithTestFlow(_ testFlow:RAUITestFlow, address:String, previousAddress previousAddressSelected:String? = nil) {
        testFlow.showPickerAddressFromPickUp()
        XCTAssertTrue(testFlow.pickerAddressVCInspector.recentPlaceCells.count <= 10)
        
        if let previousAddress = previousAddressSelected {
            XCTAssertTrue(testFlow.pickerAddressVCInspector.recentPlaceCells.first!.label.contains(previousAddress))
        }
        
        testFlow.clearAndType(address: address)
        testFlow.appTables.cells.element(boundBy: 0).forceTap()
        waitForElementToAppear(element: testFlow.mapHelper.pickUpTextField)
    }

}

