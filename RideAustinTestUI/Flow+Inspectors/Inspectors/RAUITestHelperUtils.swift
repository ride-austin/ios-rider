//
//  RAUITestHelperUtils.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import PassKit

class RAUITestHelperUtils {
    
    static func containStrictSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }
        
        return array1 == array2
    }
    
    static func containSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }
        
        return array1.sorted() == array2.sorted()
    }
    
    static func isApplePayAvailable()->Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }

}
