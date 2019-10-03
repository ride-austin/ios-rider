//
//  RAUITestFlow.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestFlow {
    
    let testCase: XCTestCase
    var app: XCUIApplication
    let splashHelper: RAUITestHelperSplash
    let registerHelper: RAUITestHelperRegister
    let roundUpHelper: RAUITestHelperRoundUp
    let driverRegistrationHelper: RAUITestHelperDriverRegistration
    let loginHelper: RAUITestHelperLogin
    let mapHelper: RAUITestHelperMap
    let ratingHelper: RAUITestHelperRating
    let favoritePlacesHelper: RAUITestHelperFavoritePlace
    let rideCostsHelper: RAUITestHelperRideCosts
    let creditCardManagementHelper: RAUITestHelperCreditCardManagement
    let lostItemsFormVCInspector: LostItemsFormViewControllerInspector
    let supportTableVCInspector: SupportTableViewControllerInspector
    let pickerAddressVCInspector: RAUITestHelperPickerAdddress
    let contactSupportVCInspector: RAUITestHelperContactSupport
    
    init(_ testCase: XCTestCase, launchArguments: [String], launchEnvironment:[String:String]) {
        self.testCase = testCase
        app = XCUIApplication(launchArguments: launchArguments, launchEnvironment: launchEnvironment)
        splashHelper = RAUITestHelperSplash(app)
        registerHelper = RAUITestHelperRegister(app)
        roundUpHelper = RAUITestHelperRoundUp(app)
        driverRegistrationHelper = RAUITestHelperDriverRegistration(app)
        loginHelper = RAUITestHelperLogin(app)
        mapHelper = RAUITestHelperMap(app)
        ratingHelper = RAUITestHelperRating(app)
        favoritePlacesHelper = RAUITestHelperFavoritePlace(app)
        rideCostsHelper = RAUITestHelperRideCosts(app)
        creditCardManagementHelper = RAUITestHelperCreditCardManagement(app)
        lostItemsFormVCInspector = LostItemsFormViewControllerInspector(app)
        supportTableVCInspector  = SupportTableViewControllerInspector(app)
        pickerAddressVCInspector = RAUITestHelperPickerAdddress(app)
        contactSupportVCInspector = RAUITestHelperContactSupport(app)
    }
    
    convenience init(_ testCase: XCTestCase, launchEnvironment:[String:String]) {
        self.init(testCase, launchArguments: [], launchEnvironment: launchEnvironment)
    }
    
    convenience init(_ testCase: XCTestCase, launchArguments: [String]) {
        self.init(testCase, launchArguments: launchArguments, launchEnvironment: [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoAuth])
    }
    
    convenience init(_ testCase: XCTestCase, configuration: String = XCUIApplication.XCUIAppArgumentConfigurationDefault, arguments: [String]? = nil, behavior: String = XCUIApplication.XCUIAppBehaviorNoAuth) {
        var args = [XCUIApplication.XCUIAppArgumentConfiguration, configuration]
        if let otherArgs = arguments {
            args += otherArgs
        }
        self.init(testCase, launchArguments: args, launchEnvironment: [XCUIApplication.XCUIAppEnvironmentAutomation:behavior])
    }
    
    func launchApp(){
        app.launch()
    }
}
