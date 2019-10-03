//
//  CLLocation+isValid.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (isValid)

+ (BOOL)isCoordinateNonZero:(CLLocationCoordinate2D)coordinate;

@end
