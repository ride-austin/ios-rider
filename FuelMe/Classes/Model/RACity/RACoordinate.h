//
//  RACoordinate.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/28/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <CoreLocation/CoreLocation.h>

@interface RACoordinate : MTLModel <MTLJSONSerializing>

- (CLLocation *)location;
- (CLLocationCoordinate2D)coordinate;

@end
