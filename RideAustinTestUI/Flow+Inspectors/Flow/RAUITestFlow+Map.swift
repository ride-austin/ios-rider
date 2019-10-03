//
//  RAUITestFlow+Common.swift
//  Ride
//
//  Created by Marcos Alba on 25/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

// Map

extension RAUITestFlow {
    
    func tapOnMap() {
        mapHelper.mapView.tap()
    }
    
    func tapOnMenu() {
        mapHelper.navigationMenuButton.tap()
    }

    func tapOnRequestRideButton() {
        let requestBtn = mapHelper.requestRideButton
        XCTAssertTrue(requestBtn.exists && requestBtn.isEnabled)
        requestBtn.tap()
        
        tryPushNotificationReminder()
    }
    
    func launchAppToMapInInitialState() {
        app.launch()
        goToMapInInitialState()
    }
    
    func launchAppToMapInInitialState(withUser: Account) {
        app.launch()
        signIn(withUser)
        
        let pickUpButton = mapHelper.setPickUpButton
        testCase.waitForElementToAppear(element: pickUpButton, timeout: 15)
        
        let requestRideView = mapHelper.requestView
        if requestRideView.exists {
            tapCancelRequest()
            testCase.waitForElementToAppear(element: pickUpButton)
        }
        
        mapHelper.assertMapViewInState(.Initial)
    }
    
    func goToMapInInitialState() {
        signInSuccess()
        
        let pickUpButton = mapHelper.setPickUpButton
        testCase.waitForElementToAppear(element: pickUpButton, timeout: 15)
        
        let requestRideView = mapHelper.requestView
        if requestRideView.exists {
            tapCancelRequest()
            testCase.waitForElementToAppear(element: pickUpButton)
        }
        
        mapHelper.assertMapViewInState(.Initial)
    }
    
    func goToConfirmationScreenWithPickUp(_ pickUp: String, destination: String? = nil){
        testCase.waitForElementToAppear(element: mapHelper.setPickUpButton)
        if let dest = destination {
            setDestinationAt(dest)
        }
        setPickUpAt(pickUp)
        testCase.waitForElementToAppear(element: mapHelper.requestView)
        if destination != nil {
            mapHelper.assertMapViewInState(.ConfirmationWithDestination)
        } else{
            mapHelper.assertMapViewInState(.Confirmation)
        }
    }
    
    func waitForRequestViewAndTapCancel() {
        let requestRideView = mapHelper.requestView
        testCase.waitForElementToAppear(element: requestRideView)
        tapCancelRequest()
    }
    
    func tapCancelRequest() {
        mapHelper.requestCancelButton.tap()
    }
    
    func tryApplePayScreen() {
        let btDisable = mapHelper.disableRoundUpButton
        if btDisable.exists {
            btDisable.tap()
        }
    }
    
    func tryPushNotificationReminder() {
        if mapHelper.closePushNotification.exists {
            mapHelper.closePushNotification.tap()
        }
    }
    
    func waitForMapChangingToState(_ state: RAUITestHelperMap.MapViewState, timeout: TimeInterval = 5){
        testCase.waitForElementToAppear(element: mapHelper.identifierForState(state), timeout:timeout)
        mapHelper.assertMapViewInState(state)
    }
    
    func requestRideFrom(_ pickUp: String, to destination: String? = nil, launchApp: Bool = true){
        if launchApp {
            launchAppToMapInInitialState()
        }
        goToConfirmationScreenWithPickUp(pickUp, destination: destination)
        tapOnRequestRideButton()
        tryPushNotificationReminder()
        tryApplePayScreen()
        waitForMapChangingToState(.Requesting)
    }
    
    // TO DO: show/hide
    func showDriverInfoView() {
        let coordinate: XCUICoordinate = mapHelper.driverInfoView.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        coordinate.tap()
    }
    
    func cancelTrip() {
        mapHelper.cancelTripButton.tap()
    }
    
    func pressFareEstimate(){
        mapHelper.fareEstimateButton.tap()
    }
    
    func waitForRideCancellationAlertToAppear(_ timeout: TimeInterval = 5){
        testCase.waitForElementToAppear(element: mapHelper.rideCancellationAlert)
    }
    
    func cancellationFee() -> Float {
        let cancellationFeeLabel = mapHelper.cancellationFeeLabel
        testCase.waitForElementToAppear(element: cancellationFeeLabel, timeout: 30)
        var cancellationFeeString = cancellationFeeLabel.label.replacingOccurrences(of: "$", with: "")
        cancellationFeeString = cancellationFeeString.replacingOccurrences(of: " cancellation fee.", with: "")
        
        return Float(cancellationFeeString)!
    }

}

// MARK: Address Fields

extension RAUITestFlow {
    
    func clearAndType(address addess:String, tapBefore:Bool = true) {
        let pickerAddress = pickerAddressVCInspector.txtAddress
        if tapBefore {
            pickerAddress.forceTap()
            sleep(1)
        }
        pickerAddress.clearAndTypeText(addess)
    }
    
    func clearPickUpAndTypeText(_ text: String, tapBefore: Bool = true) {
        let pickUpTextField = pickerAddressVCInspector.txtAddress
        if tapBefore {
            pickUpTextField.forceTap()
            sleep(1)
        }
        pickUpTextField.clearAndTypeText(text)
    }
    
    func clearDestinationAndTypeText(_ text: String, tapBefore: Bool = true) {
        let destinationTextField = mapHelper.destinationTextField
        if tapBefore {
            destinationTextField.forceTap()
            sleep(1)
        }
        destinationTextField.clearAndTypeText(text)
    }
    
    func goToAddress(_ address: String){
        mapHelper.pickUpTextField.forceTap()
        testCase.waitForElementToAppear(element: pickerAddressVCInspector.txtAddress)
        clearAndType(address: address)
        appTables.cells.element(boundBy: 0).forceTap()
        testCase.waitForElementToAppear(element: mapHelper.pickUpTextField)
    }
    
    func setPickUpAt(_ address: String) {
        goToAddress(address)
        sleep(1)
        mapHelper.setPickUpButton.tap()
        sleep(1) // use waitForelement to appear ¿?
        tapYesIfExists()
    }
    
    func setDestinationAt(_ address: String) {
        mapHelper.destinationTextField.forceTap()
        testCase.waitForElementToAppear(element: pickerAddressVCInspector.txtAddress)
        clearAndType(address:address)
        appTables.cells.element(boundBy: 0).forceTap()
        testCase.waitForElementToAppear(element: mapHelper.destinationTextField)
    }
    
    func forceTapOnPickUpButton() {
        mapHelper.setPickUpButton.forceTap()
    }

    func waitForPickUpTextFieldAndTap() {
        let pickUpTextField = mapHelper.pickUpTextField
        if !pickUpTextField.exists {
            testCase.waitForElementToAppear(element: pickUpTextField)
        }
        pickUpTextField.tap()
    }
}

// MARK: Ride Comment

extension RAUITestFlow {
    
    func clearComment(tapBefore: Bool = true) {
        func clear() {
            mapHelper.commentTextField.tapClear()
            mapHelper.commentTextField.typeText("\n")
        }

        if tapBefore {
            mapHelper.commentTextField.tap()
        }

        guard getComment() != nil else {
            return
        }
        
        clear()
    }
    
    func writeComment(_ text: String, tapBefore: Bool = true) {
        if tapBefore {
            mapHelper.commentTextField.tap()
        }
        mapHelper.commentTextField.clearAndTypeText(text + "\n")
    }
    
    func getComment() -> String? {
        let commentTF = mapHelper.commentTextField
        guard commentTF.exists, let comment = commentTF.value as? String else {
            return nil
        }
        return comment
    }
}

// MARK: Car Categories

extension RAUITestFlow {
    enum CarCategory: String {
        case Standard = "STANDARD"
        case SUV = "SUV"
        case Premium = "PREMIUM"
        case Luxury = "LUXURY"
    }
    
    func getCarCategory(_ category: CarCategory) -> XCUIElement {
        let p = NSPredicate(format: "label CONTAINS %@", category.rawValue)
        return app.buttons.containing(p).element
    }
    
    func isSelectedCarCategory(_ category: CarCategory) -> Bool {
        let catJSONString = getCarCategory(category).label
        guard let jsonData = catJSONString.data(using: .utf8) else {
            return false
        }
        do {
            let catDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String]
            guard let selectedString = catDict?["selected"] else {
                return false
            }
            guard let selected = Bool(selectedString) else {
                return false
            }
            return selected
        }
        catch {
            print("Json serialization error: \(error)")
            return false
        }
    }
    
    func tapCarCategory(_ carCategory: CarCategory, evenIfSelected:Bool = true) {
        let selected = isSelectedCarCategory(carCategory)
        
        if !selected || (selected && evenIfSelected){
            getCarCategory(carCategory).tap()
        }
    }
    
    func tapCarCategorySliderButton() {
        let sliderButton = mapHelper.carCategoriesSliderButton
        XCTAssertTrue(sliderButton.exists)
        sliderButton.tap()
    }
    
    func getDetailsForCategory(_ category:CarCategory) -> (eta: UInt, maxSize: UInt) {
        tapCarCategory(category, evenIfSelected: false)
        
        let etaLabel = mapHelper.ETALabel.label
        let etaNumberText = etaLabel.replacingOccurrences(of: "ETA ", with: "").replacingOccurrences(of: " minutes", with: "")
        var eta: UInt! = UInt(etaNumberText)
        if eta == nil {
            eta = UInt(0)
        }
        
        let maxSizeLabel = mapHelper.maxSizePeopleLabel.label
        let maxSizeText = maxSizeLabel.replacingOccurrences(of: "Max Size ", with: "").replacingOccurrences(of: " people", with: "")
        var maxSize: UInt! = UInt(maxSizeText)
        if maxSize == nil {
            maxSize = UInt(0)
        }
        
        return (eta,maxSize)
    }
    
    func assertSelectedCategory(_ carCategory: CarCategory) {
        XCTAssertTrue(isSelectedCarCategory(carCategory))
    }
}

//MARK: Recent Places

extension RAUITestFlow {
    
    func showPickerAddressFromPickUp() {
        testCase.waitForElementToAppear(element: mapHelper.pickUpTextField)
        mapHelper.pickUpTextField.tap()
        let addressResults = pickerAddressVCInspector.tblAddressResult
        testCase.waitForElementToAppear(element: addressResults)
    }
    
    func showPickerAddressFromDestination() {
        mapHelper.destinationTextField.tap()
        testCase.waitForElementToAppear(element: pickerAddressVCInspector.tblAddressResult)
    }
    
    func addPlaceToRecentPlaces(_ text: String) {
        waitForPickUpTextFieldAndTap()
        clearPickUpAndTypeText(text, tapBefore: false)
        appTables.cells.element(boundBy: 0).tap()
    }

}

//MARK: Active Drivers 

extension RAUITestFlow {
    func getIDForActiveDriverAtIndex(_ index: UInt) -> String {
        let acdrs = mapHelper.activeDrivers
        if !acdrs.element.exists {
            testCase.waitForElementToAppear(element: acdrs.element)
        }
        XCTAssertTrue(index < acdrs.count)
        let acdrLabel = acdrs.element(boundBy: Int(index)).label
        let components = acdrLabel.components(separatedBy: ":")
        XCTAssertTrue(components.count == 2)
        return components[1]
    }

}

//MARK: Pricing Details

extension RAUITestFlow {
    func openPricingDetailsForCategory(_ category: CarCategory){
        tapCarCategory(category, evenIfSelected: false)
        
        let viewPricingButton = mapHelper.viewPricingButton
        if !viewPricingButton.isHittable {
            tapCarCategorySliderButton()
            testCase.waitForElementToBeHittable(element: viewPricingButton)
        }
        viewPricingButton.tap()
        
        let pricingTable = rideCostsHelper.pricingDetailsTableView
        testCase.waitForElementToAppear(element: pricingTable)
    }
    
    func closePricingDetails() {
        if rideCostsHelper.pricingDetailsView.exists {
            rideCostsHelper.pricingDetailsView.tap()
        }
    }
}

//MARK: Ride Costs

extension RAUITestFlow {
    func getRideCostsForCategory(_ category: CarCategory, closeAfter timeout: UInt32 = 1) -> (basFare: Float, perMile: Float, perMin: Float, minFare: Float, bookingFee: Float, cityFee: Float, processingFee: Float) {
        openPricingDetailsForCategory(category)
        
        let baseFare = Float(rideCostsHelper.baseFareCell.value as! String)!
        let perMile = Float(rideCostsHelper.perMileCell.value as! String)!
        let perMin = Float(rideCostsHelper.perMinCell.value as! String)!
        let minFare = Float(rideCostsHelper.minFareCell.value as! String)!
        let bookingFee = Float(rideCostsHelper.bookingFeeCell.value as! String)!
        let cityFee = Float(rideCostsHelper.cityFeeCell.value as! String)!
        let processingFee = Float(rideCostsHelper.processingFeeCell.value as! String)!
        
        sleep(timeout)
        
        closePricingDetails()
        
        return(baseFare,perMile,perMin,minFare,bookingFee,cityFee,processingFee)
    }
}

// MARK: Car Upgrade Request

extension RAUITestFlow {
    
    func waitForCarUpgradeRequest(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: mapHelper.carUpgradeRequestAlert, timeout: timeout)
        mapHelper.assertUpgradeRequest()
    }
    
    func pressCancelUpgradeRequest() {
        mapHelper.carUpgradeRequestCancelButton.tap()
    }

    func pressConfirmUpgradeRequest() {
        mapHelper.carUpgradeRequestConfirmButton.tap()
    }

    func pressDeclineUpgradeRequest() {
        mapHelper.carUpgradeRequestDeclineButton.tap()
    }

    func waitForCarUpgradeRequestToDisappear(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToDisappear(mapHelper.carUpgradeRequestAlert, timeout: timeout)
    }
    
    func waitForSuccessHUDToAppear(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: mapHelper.successHUD, timeout: timeout)
    }
    
    func waitForUpgradeCancelledAlertToAppear(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: mapHelper.carUpgradeCancelledAlert, timeout: timeout)
    }
    
    func waitForUpgradeExpiredAlertToAppear(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: mapHelper.carUpgradeExpiredAlert, timeout: timeout)
    }
    
    func assertPriortiyFare(_ pf: Float) {
        if pf <= 1 {
            XCTAssertFalse(mapHelper.carUpgradeRequestPriorityFareLabel.exists)
        }
        else {
            XCTAssertTrue(mapHelper.carUpgradeRequestPriorityFareLabel.exists)
            let pfString = "PRIORITY FARE: \(String(format: "%.2f",pf))X"
            XCTAssertTrue(mapHelper.carUpgradePriorityFare == pfString)
        }
    }
}

// MARK: Driver Info

extension RAUITestFlow {
    
    func assertDriverInfoShowsCategory(_ carCategory: CarCategory) {
        testCase.waitForElementToAppear(element: mapHelper.driverInfoView.staticTexts[carCategory.rawValue], timeout: 2)
    }
    
}

// MARK : Estimated Fare

extension RAUITestFlow {
    
    func waitForEstimatedFareViewtoAppear(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: mapHelper.estimaedFareView,timeout: timeout)
    }
    
    func assertEstimatedFareIs(_ ef: Float){
        XCTAssertTrue(mapHelper.estimatedFare == ef)
    }
    
}

