//
//  CapMetroValidator.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/11/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CapMetroValidator : NSObject
- (BOOL)isValidStart:(CLLocationCoordinate2D)startCoordinate andEndCoordinate:(CLLocationCoordinate2D)endCoordinate;
@end
