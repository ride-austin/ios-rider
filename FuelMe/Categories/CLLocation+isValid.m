//
//  CLLocation+isValid.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CLLocation+isValid.h"

@implementation CLLocation (isValid)

+ (BOOL)isCoordinateNonZero:(CLLocationCoordinate2D)coordinate {
    // if we have 0,0 then that puts us in africa and means the coordinate wasnt set as it defaults to 0,0
    return CLLocationCoordinate2DIsValid(coordinate) && coordinate.latitude != 0 && coordinate.longitude != 0;
}

@end
