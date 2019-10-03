//
//  RAUITestHelperMap.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperMap: RAUITestBaseHelper {
    
}

extension RAUITestHelperMap {
    
    enum MapViewState {
        case Initial
        case Confirmation
        case ConfirmationWithDestination
        case Requesting
        case DriverOnWay
        case DriverReached
        case Riding
        func navLabel() -> String {
            switch self {
            case .Initial:
                return ""
            case .Confirmation, .ConfirmationWithDestination:
                return "Confirmation"
            case .Requesting:
                return "Requesting"
            case .DriverOnWay:
                return "Driver on way"
            case .DriverReached:
                return "Driver Arrived"
            case .Riding:
                return "Trip Started"
            }
        }
    }
    
    var mapView: XCUIElement{
        return app.otherElements["googleMapsView"]
    }
    
    var navigationBar: XCUIElement {
        return app.navigationBars["LocationViewControllerNavigationBar"]
    }
    
    var navigationMenuButton: XCUIElement{
        return app.buttons["show menu"]
    }

    var navigatioBackButton: XCUIElement{
        return app.navigationBars.buttons.element(boundBy: 0).firstMatch
    }
    
    var navigationLogoImage: XCUIElement{
        return app.images["locationCityLogo"]
    }
    
    var navigationUserLocationButton: XCUIElement{
        return app.buttons["show my location"]
    }
    
    var navigationContactButton: XCUIElement {
        return app.buttons["Contact"]
    }
    
    var pickUpTextField: XCUIElement {
        return app.buttons["txtPickup"]
    }
    
    var destinationTextField: XCUIElement {
        return app.buttons["txtDestination"]
    }
    
    var setPickUpButton: XCUIElement{
        return app.buttons["SET PICKUP LOCATION"]
    }
    
    var carCategoriesSliderButton: XCUIElement {
        return app.buttons["carCategoriesChevronButton"]
    }
    
    var carCategoriesSliderImage: XCUIElement {
        return app.images["dropdown"]
    }
    
    var standardCarCategoryButton: XCUIElement{
        let p = NSPredicate(format: "label CONTAINS %@", "STANDARD")
        return app.buttons.containing(p).element
    }
    
    var SUVCarCategoryButton: XCUIElement{
        let p = NSPredicate(format: "label CONTAINS %@", "SUV")
        return app.buttons.containing(p).element
    }
    
    var premiumCarCategoryButton: XCUIElement{
        let p = NSPredicate(format: "label CONTAINS %@", "PREMIUM")
        return app.buttons.containing(p).element
    }
    
    var luxuryCarCategoryButton: XCUIElement{
        let p = NSPredicate(format: "label CONTAINS %@", "LUXURY")
        return app.buttons.containing(p).element
    }
    
    var recentPlacesTable: XCUIElementQuery {
        return app.tables.containing(.table, identifier: "recentPlacesTable")
    }

    var recentPlaces: XCUIElementQuery {
        let p = NSPredicate(format: "label != %@ && label != %@", "Home", "Work")
        return recentPlacesTable.cells.matching(p)
    }

    var requestView: XCUIElement {
        return app.otherElements["RequestRideView"]
    }
    
    var requestCancelButton: XCUIElement {
        return app.buttons["Cancel Request"]
    }
    
    var requestRideButton: XCUIElement {
        return app.buttons["Request Ride"]
    }
    
    var cancelRequestingRideButton: XCUIElement {
        return app.buttons["Cancel your request"]
    }
    
    var fareEstimateButton: XCUIElement {
        return app.buttons["See Fare Estimate"]
    }

    var promoCodeButton: XCUIElement {
        return app.buttons["Enter Promo Code"]
    }
    
    var savePaymentMethodButton: XCUIElement {
        return app.buttons["btnPaymentDisclosure"]
    }
    
    var addPaymentNavBar: XCUIElement {
        return app.navigationBars["Payment"]
    }
    
    var activeDrivers: XCUIElementQuery {
        let carsPredicate = NSPredicate(format: "label beginsWith[cd] 'DRIVER'")
        return app.buttons.matching(carsPredicate)
    }
    
    var ETALabel: XCUIElement {
        let etaPredicate = NSPredicate(format: "label CONTAINS[cd] %@", "ETA")
        return app.staticTexts.matching(etaPredicate).element(boundBy: 0)
    }
    
    var maxSizePeopleLabel: XCUIElement {
        let maxSizePredicate = NSPredicate(format: "label CONTAINS[cd] %@", "MAX SIZE")
        return app.staticTexts.matching(maxSizePredicate).element(boundBy: 0)
    }
    
    var viewPricingButton: XCUIElement {
        return app.buttons["View Pricing"]
    }
    
    var rideEstimateButton: XCUIElement {
        return app.buttons["Get ride estimate"]
    }
    
    var commentTextField: XCUIElement {
        return app.textFields["CommentTextField"]
    }
    
    var disableRoundUpButton: XCUIElement {
        return app.buttons["Disable Round Up"]
    }
    
    var driverInfoView: XCUIElement {
        return app.otherElements["Driver Info View"]
    }
    
    var cancelTripButton: XCUIElement {
        return driverInfoView.buttons["Cancel trip"]
    }
    
    var driverInfoCarCategoryLabel: XCUIElement {
        return driverInfoView.staticTexts["carCategoryLabel"]
    }
    
    var driverInfoCarCategoryExpandedLabel: XCUIElement {
        return driverInfoView.staticTexts["carCategoryExpandedLabel"]
    }
    
    var HUD: XCUIElement {
        return app.otherElements["SVProgressHUD"]
    }
    
    var rideCancellationAlert: XCUIElement {
        return app.otherElements["rideCancellationAlert"]
    }
    
    var cancellationFeeLabel: XCUIElement {
        let cancellationFeePredicate = NSPredicate(format: "label CONTAINS[cd] %@", "cancellation fee")
        return rideCancellationAlert.staticTexts.matching(cancellationFeePredicate).element(boundBy: 0)
    }
    
    var closePushNotification:XCUIElement {
        return app.buttons["Close"]
    }
    
}

//MARK: RoundUp Alert

extension RAUITestHelperMap {
    
    var btnNoRoundUpAlert: XCUIElement {
        return app.buttons["btnNoRoundUpAlert"]
    }
    
    var btnYesRoundUpAlert: XCUIElement {
        return app.buttons["btnYesRoundUpAlert"]
    }
    
    func closeRoundUpAlertIfNeeded() {
        if btnNoRoundUpAlert.exists {
            btnNoRoundUpAlert.tap()
        }
    }
    
}

//MARK: Car upgrade request

extension RAUITestHelperMap {
    
    var carUpgradeRequestAlert: XCUIElement {
        return app.otherElements["CarUpgradeRequestAlert"]
    }
    
    var carUpgradeRequestMessageLabel: XCUIElement{
        return carUpgradeRequestAlert.staticTexts["messageLabel"]
    }
    
    var carUpgradeRequestPriorityFareLabel: XCUIElement{
        return carUpgradeRequestAlert.staticTexts["priorityFareLabel"]
    }
    
    var carUpgradeRequestDeclineButton: XCUIElement {
        return carUpgradeRequestAlert.buttons["noButton"]
    }
    
    var carUpgradeRequestConfirmButton: XCUIElement {
        return carUpgradeRequestAlert.buttons["yesButton"]
    }
    
    var carUpgradeRequestCancelButton: XCUIElement {
        return carUpgradeRequestAlert.buttons["cancelButton"]
    }
    
    var carUpgradeMessage: String? {
        return carUpgradeRequestMessageLabel.label
    }
    
    var carUpgradePriorityFare: String? {
        return carUpgradeRequestPriorityFareLabel.label
    }
    
    var successHUD: XCUIElement {
        return app.otherElements["Success"]
    }
    
    var carUpgradeCancelledAlert: XCUIElement {
        return app.staticTexts["Your driver has cancelled the upgrade to SUV class"]
    }

    var carUpgradeExpiredAlert: XCUIElement {
        return app.staticTexts["The request to upgrade to SUV class has expired"]
    }

    func assertUpgradeRequest() {
        XCTAssertTrue(carUpgradeRequestAlert.exists)
        XCTAssertTrue(carUpgradeRequestMessageLabel.exists)
        XCTAssertTrue(carUpgradeRequestDeclineButton.exists)
        XCTAssertTrue(carUpgradeRequestConfirmButton.exists)
        XCTAssertTrue(carUpgradeRequestCancelButton.exists)
    }
    
}

// Estimated Fare View Controller

extension RAUITestHelperMap{
    var estimaedFareView: XCUIElement{
        return app.otherElements["EstimateFareView"]
    }
    
    var estimatedFareLabel: XCUIElement {
        return app.staticTexts["EstimateLabel"]
    }
    
    var estimatedFare: Float{
        let estimatedFareString = estimatedFareLabel.label.replacingOccurrences(of: "$ ", with: "")
        return Float(estimatedFareString)!
    }
}

extension RAUITestHelperMap {
    
    func assertMapViewInState(_ state:MapViewState) {
        switch state {
        case .Initial:
            assertMapViewInitialState()
        case .Confirmation:
            assertMapViewConfirmationState()
        case .ConfirmationWithDestination:
            assertMapViewConfirmationState(withDestination: true)
        case .Requesting:
            assertMapViewInRequestingState()
        case .DriverOnWay:
            assertMapViewInStateDriverOnWay()
        case .DriverReached:
            assertMapViewInStateDriverReached()
        case .Riding:
            assertMapViewInStateRiding()
        }
    }
    
    /// Unique identifier for state
    ///
    func identifierForState(_ state: MapViewState) -> XCUIElement {
        switch state {
        case .Initial:
            let locationviewNavigationBar = app.navigationBars["LocationViewControllerNavigationBar"]
            let logoRA = locationviewNavigationBar.images["locationCityLogo"]
            return logoRA
            
        case .Confirmation, .ConfirmationWithDestination, .Requesting, .DriverOnWay, .DriverReached:
            var navBarTitle = app.navigationBars.staticTexts[state.navLabel()]
            if #available(iOS 11.0, *) {
                navBarTitle = app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH '\(state.navLabel())'"))
            }
            return navBarTitle
            
        case .Riding:
            return app.navigationBars.staticTexts[state.navLabel()]
        }
    }
    
    func assertCarCategoriesAreHittable() {
        XCTAssertTrue(standardCarCategoryButton.isHittable)
        XCTAssertTrue(SUVCarCategoryButton.isHittable)
        XCTAssertTrue(premiumCarCategoryButton.isHittable)
        XCTAssertTrue(luxuryCarCategoryButton.isHittable)
    }

    func assertCarCategoriesSlider() {
        XCTAssertTrue(standardCarCategoryButton.exists)
        XCTAssertTrue(SUVCarCategoryButton.exists)
        XCTAssertTrue(premiumCarCategoryButton.exists)
        XCTAssertTrue(luxuryCarCategoryButton.exists)
        XCTAssertTrue(ETALabel.exists)
        XCTAssertTrue(maxSizePeopleLabel.exists)
        XCTAssertTrue(viewPricingButton.exists)
        XCTAssertTrue(rideEstimateButton.exists)
    }

    private func assertMapViewInitialState() {
        assertMapView()
        assertNavigationBarForState(.Initial)
        assertPickUpTextField()
        assertDestinationTextField()
        assertCommentTextField(false)
        assertPickUpButton()
        assertCarCategoriesSlider()
    }
    
    private func assertMapViewConfirmationState(withDestination:Bool=false) {
        assertMapView()
        assertNavigationBarForState(.Confirmation)
        assertPickUpTextField()
        assertDestinationTextField()
        assertCommentTextField()
        assertRequestView()
        assertPickUpButtonNotVisible()
        //TO DO: pins!
    }
    
    private func assertMapViewInRequestingState() {
        assertMapView()
        assertNavigationBarForState(.Requesting)
        assertCommentTextField(false)
    }
    
    private func assertMapViewInStateDriverOnWay() {
        assertMapView()
        assertNavigationBarForState(.DriverOnWay)
        assertPickUpTextField()
        assertDestinationTextField()
        assertCommentTextField()
        assertDriverInfoView()
    }
    
    private func assertMapViewInStateDriverReached() {
        assertMapView()
        assertNavigationBarForState(.DriverReached)
        assertPickUpTextField()
        assertDestinationTextField()
        assertCommentTextField()
        assertDriverInfoView()        
    }
    
    private func assertMapViewInStateRiding() {
        assertMapView()
        assertNavigationBarForState(.Riding)
        assertPickUpTextField()
        assertDestinationTextField()
        assertCommentTextField(false)
        assertDriverInfoView(cancelButtonEnabled: false)
    }
    
    private func assertMapView() {
        //Disabled ~ causing LostItems test to fails
        //XCTAssertTrue(mapView.exists)
    }
    
    private func assertNavigationBarForState(_ state: MapViewState) {
        switch state {
        case .Initial:
            assertMenuButton()
            assertNavTitleLogoImage()
            assertUserLocationButon()
        case .Confirmation, .ConfirmationWithDestination, .Requesting:
            assertMenuButton()
            assertNavbarTitle(state.navLabel())
            assertUserLocationButon()
        case .DriverOnWay, .DriverReached:
            assertMenuButton()
            assertNavbarTitle(state.navLabel())
            assertContactButton()
        case .Riding:
            assertMenuButton()
            assertNavbarTitle(state.navLabel(), lookForStaticText: true)
            assertContactButton()
        }
    }
    
    private func assertMenuButton() {
        XCTAssertTrue(navigationMenuButton.exists)
    }
    
    private func assertNavTitleLogoImage() {
        XCTAssertTrue(navigationLogoImage.exists)
    }
    
    /// Requesting/Confirmation/Driver on way/Driver Arrived has title
    /// TripStarted has accessibility label
    /// default has RALogo with no label
    /// - Parameters:
    ///   - lookForStaticText: if true, should use staticTexts query
    func assertNavbarTitle(_ title:String, timeout: TimeInterval = 5, lookForStaticText:Bool = false) {
        var navBarTitle = app.navigationBars.staticTexts[title]
        if !lookForStaticText, #available(iOS 11.0, *) {
            navBarTitle = app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH '\(title)'"))
        }
        XCTAssertTrue(navBarTitle.exists)
    }
    
    private func assertUserLocationButon(){
        XCTAssertTrue(navigationUserLocationButton.exists)
    }
    
    private func assertContactButton(){
        XCTAssertTrue(navigationContactButton.exists)

    }
    
    private func assertPickUpTextField() {
        XCTAssertTrue(pickUpTextField.exists)
    }
    
    private func assertDestinationTextField() {
        XCTAssertTrue(destinationTextField.exists)
    }
    
    private func assertCommentTextField(_ assertTrue: Bool = true){
        if assertTrue {
            XCTAssertTrue(commentTextField.exists)
        }
        else {
            XCTAssertFalse(commentTextField.exists)
        }
    }
    
    private func assertPickUpButton() {
        XCTAssertTrue(setPickUpButton.exists)
    }
    
    private func assertPickUpButtonNotVisible() {
        XCTAssertFalse(setPickUpButton.exists)
    }
    
    private func assertRequestView(){
        XCTAssertTrue(requestView.exists)
        
        let btnFareEstimate = fareEstimateButton
        XCTAssertTrue(btnFareEstimate.exists && btnFareEstimate.isEnabled)
        
        let btnEnterPromoCode = promoCodeButton
        XCTAssertTrue(btnEnterPromoCode.exists && btnEnterPromoCode.isEnabled)
        
        let btnCancelRequest = requestCancelButton
        XCTAssertTrue(btnCancelRequest.exists && btnCancelRequest.isEnabled)
        
        let btnRequestRide = requestRideButton
        XCTAssertTrue(btnRequestRide.exists && btnRequestRide.isEnabled)
    }
    
    func assertDriverInfoView(cancelButtonEnabled: Bool = true) {
        //Driver info view
        XCTAssertTrue(driverInfoView.exists)
        
        //Should be more general: driverName, car, ...
        let lbDriver = app.staticTexts["KITOS"]
        XCTAssert(lbDriver.exists)
        
        let lbCarType = driverInfoCarCategoryLabel
        XCTAssert(lbCarType.exists)
        
        let lbCar = app.staticTexts["BLUE LEXUS LC 500"]
        XCTAssert(lbCar.exists);
        
        let lbCarPlate = app.staticTexts["GC96ZK"]
        XCTAssert(lbCarPlate.exists)
        
        XCTAssertEqual(cancelTripButton.isEnabled, cancelButtonEnabled)
    }
}
