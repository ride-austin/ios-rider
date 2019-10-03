//
//  RAUITestFlow+Rating.swift
//  Ride
//
//  Created by Marcos Alba on 27/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

// Rating

extension RAUITestFlow {
    
    func waitForRatingView(timeout: TimeInterval = 5){
        let btSubmit = ratingHelper.submitButton
        testCase.waitForElementToAppear(element: btSubmit, timeout: timeout)
        ratingHelper.assertRatingView()
    }
    
    func tapRating() {
        ratingHelper.ratingView.tap()
    }
    
    func tapSubmit() {
        ratingHelper.submitButton.tap()
    }

}
