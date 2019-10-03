//
//  RAUITestHelperRating.swift
//  Ride
//
//  Created by Marcos Alba on 27/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

class RAUITestHelperRating: RAUITestBaseHelper {
    
}

extension RAUITestHelperRating {
    
    var submitButton: XCUIElement {
        return app.buttons["Submit Rating"]
    }
    
    var feedBackLabel: XCUIElement {
        let p = NSPredicate(format: "label CONTAINS %@", "What feedback would you give")
        return app.staticTexts.matching(p).element
    }

    var totalFareLabel: XCUIElement {
        let p = NSPredicate(format: "label CONTAINS %@", "Total fare:")
        return app.staticTexts.matching(p).element
    }

    var creditsLabel: XCUIElement {
        return app.staticTexts["Eligible credits will be applied on your emailed receipt."]
    }
    
    var ratingView: XCUIElement {
        return  app.scrollViews.otherElements.otherElements["Rating"]
    }

}

extension RAUITestHelperRating {
   
    func assertRatingView() {
        XCTAssertTrue(submitButton.exists)
        XCTAssertTrue(feedBackLabel.exists)
        XCTAssertTrue(totalFareLabel.exists)
        XCTAssertTrue(creditsLabel.exists)
        XCTAssertTrue(ratingView.exists)
    }
    
    func rate() {
        self.ratingView.tap()
        self.submitButton.tap()
    }
}
