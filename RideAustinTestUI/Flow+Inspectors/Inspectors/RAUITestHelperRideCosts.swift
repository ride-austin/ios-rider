//
//  RAUITestHelperRideCosts.swift
//  Ride
//
//  Created by Marcos Alba on 19/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperRideCosts: RAUITestBaseHelper {

}

extension RAUITestHelperRideCosts {
    
    var pricingDetailsView: XCUIElement {
        return app.otherElements["pricingDetailsView"]
    }
    
    var pricingDetailsTableView: XCUIElement {
        return app.tables["pricingDetailsTableView"]
    }
    
    var baseFareCell: XCUIElement {
        return pricingDetailsTableView.cells["BASE FARE"]
    }

    var perMileCell: XCUIElement {
        return pricingDetailsTableView.cells["PER MILE"]
    }

    var perMinCell: XCUIElement {
        return pricingDetailsTableView.cells["PER MIN"]
    }

    var minFareCell: XCUIElement {
        return pricingDetailsTableView.cells["MINIMUM FARE"]
    }

    var bookingFeeCell: XCUIElement {
        return pricingDetailsTableView.cells["BOOKING FEE"]
    }

    var cityFeeCell: XCUIElement {
        return pricingDetailsTableView.cells["CITY TNC FEE"]
    }

    var processingFeeCell: XCUIElement {
        return pricingDetailsTableView.cells["PROCESSING FEE"]
    }

}
