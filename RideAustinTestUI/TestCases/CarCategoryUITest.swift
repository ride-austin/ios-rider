//
//  CarCategoryUITest.swift
//  Ride
//
//  Created by Marcos Alba on 17/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

//Test case 5.1.2. Requesting: Car Type Slider. https://issue-tracker.devfactory.com/browse/RA-10414

class CarCategoryUITest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // A. Rider can select car category before request (STANDARD / SUV / PREMIUM / LUXURY). https://issue-tracker.devfactory.com/browse/RA-10581
    // https://testrail.devfactory.com/index.php?/cases/view/1931519
    
    func testCarCategoryCanBeSelectedBeforeRequest_1931519() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        testFlow.goToAddress("Jollyville")
        
        func assertCanSelectCategory(_ category:RAUITestFlow.CarCategory, expectedNumberOfCars numCars:UInt, expectedMins mins:Int) {
            testFlow.tapCarCategory(category, evenIfSelected: false)
            
            let activeDrivers = testFlow.mapHelper.activeDrivers
            waitForElementToAppear(element: activeDrivers.element)
            XCTAssertEqual(activeDrivers.count, Int(numCars))
            XCTAssertTrue(testFlow.staticTexts("\(mins) MIN").exists)
        }
        
        assertCanSelectCategory(.Standard, expectedNumberOfCars: 2, expectedMins: 2)
        assertCanSelectCategory(.SUV, expectedNumberOfCars: 3, expectedMins: 3)
        assertCanSelectCategory(.Premium, expectedNumberOfCars: 3, expectedMins: 4)
        assertCanSelectCategory(.Luxury, expectedNumberOfCars: 1, expectedMins: 5)
    }
    
    // C. When selecting car category, driver cars are updated on the map. https://issue-tracker.devfactory.com/browse/RA-10583
    // https://testrail.devfactory.com/index.php?/cases/view/1931521
    
    func testC_CarsAreUpdatedWhileSwitchingThroughCategories_1931521() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        testFlow.mapHelper.assertCarCategoriesAreHittable()
        
        testFlow.goToAddress("Jollyville")
        
        testFlow.tapCarCategory(.Standard, evenIfSelected: false)
        let activeDrivers = testFlow.mapHelper.activeDrivers
        waitForElementToAppear(element: activeDrivers.element)
        XCTAssertTrue(activeDrivers.count == 2)

        var acdr1ID = testFlow.getIDForActiveDriverAtIndex(0)
        XCTAssertTrue(acdr1ID == "nearbyCar-2187" || acdr1ID == "nearbyCar-2188")
        var acdr2ID = testFlow.getIDForActiveDriverAtIndex(1)
        XCTAssertTrue(acdr2ID == "nearbyCar-2187" || acdr2ID == "nearbyCar-2188")
        
        testFlow.tapCarCategory(.SUV)
        waitForElementToAppear(element: activeDrivers.element)
        XCTAssertTrue(activeDrivers.count == 3)

        acdr1ID = testFlow.getIDForActiveDriverAtIndex(0)
        XCTAssertTrue(acdr1ID == "nearbyCar-2187" || acdr1ID == "nearbyCar-2188" || acdr1ID == "nearbyCar-2189")
        acdr2ID = testFlow.getIDForActiveDriverAtIndex(1)
        XCTAssertTrue(acdr2ID == "nearbyCar-2187" || acdr2ID == "nearbyCar-2188" || acdr2ID == "nearbyCar-2189")
        var acdr3ID = testFlow.getIDForActiveDriverAtIndex(2)
        XCTAssertTrue(acdr3ID == "nearbyCar-2187" || acdr3ID == "nearbyCar-2188" || acdr3ID == "nearbyCar-2189")
        
        testFlow.tapCarCategory(.Premium)
        waitForElementToAppear(element: activeDrivers.element)
        XCTAssertTrue(activeDrivers.count == 3)
        
        acdr1ID = testFlow.getIDForActiveDriverAtIndex(0)
        XCTAssertTrue(acdr1ID == "nearbyCar-1000" || acdr1ID == "nearbyCar-1001" || acdr1ID == "nearbyCar-1002")
        acdr2ID = testFlow.getIDForActiveDriverAtIndex(1)
        XCTAssertTrue(acdr2ID == "nearbyCar-1000" || acdr2ID == "nearbyCar-1001" || acdr2ID == "nearbyCar-1002")
        acdr3ID = testFlow.getIDForActiveDriverAtIndex(2)
        XCTAssertTrue(acdr3ID == "nearbyCar-1000" || acdr3ID == "nearbyCar-1001" || acdr3ID == "nearbyCar-1002")
        
        testFlow.tapCarCategory(.Luxury)
        waitForElementToAppear(element: activeDrivers.element)
        XCTAssertTrue(activeDrivers.count == 1)
        
        acdr1ID = testFlow.getIDForActiveDriverAtIndex(0)
        XCTAssertTrue(acdr1ID == "nearbyCar-2187")
    }
    
    // D. STANDARD car type is selected by default. https://issue-tracker.devfactory.com/browse/RA-10584
    // https://testrail.devfactory.com/index.php?/cases/view/1931522
    
    func testDStandardCategoryIsSelectedByDefault_1931522() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        XCTAssertTrue(testFlow.isSelectedCarCategory(.Standard))
    }
    
    // E. Switching categories changes ETA and MAX SIZE. https://issue-tracker.devfactory.com/browse/RA-10585
    // https://testrail.devfactory.com/index.php?/cases/view/1931523
    
    func testE_ETAAndMaxSizeChangesWhileSwitchingThroughCategories_1931523() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        testFlow.tapCarCategorySliderButton()
        
        var (eta,maxSize) = testFlow.getDetailsForCategory(.Standard)
        XCTAssertEqual(eta, 2)
        XCTAssertEqual(maxSize, 4)
        
        (eta,maxSize) = testFlow.getDetailsForCategory(.SUV)
        XCTAssertEqual(eta, 3)
        XCTAssertEqual(maxSize, 6)

        (eta,maxSize) = testFlow.getDetailsForCategory(.Premium)
        XCTAssertEqual(eta, 4)
        XCTAssertEqual(maxSize, 4)

        (eta,maxSize) = testFlow.getDetailsForCategory(.Luxury)
        XCTAssertEqual(eta, 5)
        XCTAssertEqual(maxSize, 4)
    }
    
    // F. View Pricing: Correct pricing details for each car category. https://issue-tracker.devfactory.com/browse/RA-10586
    // https://testrail.devfactory.com/index.php?/cases/view/1931524
    
    func testFViewPricingForEachCategory_1931524(){
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        var (baseFare,perMile,perMin,minFare,bookingFee,cityFee,processingFee) = testFlow.getRideCostsForCategory(.Standard)
        XCTAssertEqual(baseFare, 1.5)
        XCTAssertEqual(perMile, 0.99)
        XCTAssertEqual(perMin, 0.20)
        XCTAssertEqual(minFare, 5)
        XCTAssertEqual(bookingFee, 2)
        XCTAssertEqual(cityFee, 0)
        XCTAssertEqual(processingFee, 1)
        
        (baseFare,perMile,perMin,minFare,bookingFee,cityFee,processingFee) = testFlow.getRideCostsForCategory(.SUV)
        XCTAssertEqual(baseFare, 3)
        XCTAssertEqual(perMile, 2.0)
        XCTAssertEqual(perMin, 0.30)
        XCTAssertEqual(minFare, 9.0)
        XCTAssertEqual(bookingFee, 2)
        XCTAssertEqual(cityFee, 0)
        XCTAssertEqual(processingFee, 1)
        
        (baseFare,perMile,perMin,minFare,bookingFee,cityFee,processingFee) = testFlow.getRideCostsForCategory(.Premium)
        XCTAssertEqual(baseFare, 3)
        XCTAssertEqual(perMile, 2.75)
        XCTAssertEqual(perMin, 0.4)
        XCTAssertEqual(minFare, 10)
        XCTAssertEqual(bookingFee, 2)
        XCTAssertEqual(cityFee, 0)
        XCTAssertEqual(processingFee, 1)
        
        (baseFare,perMile,perMin,minFare,bookingFee,cityFee,processingFee) = testFlow.getRideCostsForCategory(.Luxury)
        XCTAssertEqual(baseFare, 5)
        XCTAssertEqual(perMile, 3.75)
        XCTAssertEqual(perMin, 0.5)
        XCTAssertEqual(minFare, 10)
        XCTAssertEqual(bookingFee, 2)
        XCTAssertEqual(cityFee, 0)
        XCTAssertEqual(processingFee, 1)
    }
    
    // G. A '^' shown as a slide up indicator above the car categories. https://issue-tracker.devfactory.com/browse/RA-10587
    // https://testrail.devfactory.com/index.php?/cases/view/1931525
    
    func testGSlideIndicatorIsShownAboveCategories_1931525() {
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        let sliderButton = testFlow.mapHelper.carCategoriesSliderButton
        XCTAssertTrue(sliderButton.exists)
        
        let dropDownImage = testFlow.mapHelper.carCategoriesSliderImage
        XCTAssertTrue(dropDownImage.exists)
        
        let standardCategory = testFlow.mapHelper.standardCarCategoryButton
        XCTAssertTrue(standardCategory.exists)
        
        XCTAssertGreaterThan(standardCategory.frame.minY, sliderButton.frame.maxX)
        XCTAssertGreaterThan(standardCategory.frame.minY, dropDownImage.frame.maxX)
    }
    
    // H: Able to slide up the car categories to reveal more actions . https://issue-tracker.devfactory.com/browse/RA-10588
    // https://testrail.devfactory.com/index.php?/cases/view/1931526
    
    func testHSlideUpCarCategories_1931526(){
        let testFlow = RAUITestFlow(self)
        testFlow.launchAppToMapInInitialState()
        
        let sliderButton = testFlow.mapHelper.carCategoriesSliderButton
        XCTAssertTrue(sliderButton.exists)

        let frameBefore = sliderButton.frame
        
        testFlow.tapCarCategorySliderButton()
        sleep(1)

        let frameAfter = sliderButton.frame
        
        XCTAssertGreaterThan(frameBefore.midY, frameAfter.midY)
    }
}
