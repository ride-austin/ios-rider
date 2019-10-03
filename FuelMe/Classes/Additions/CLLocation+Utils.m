//
//  CLLocation+Equality.m
//  Ride
//
//  Created by Roberto Abreu on 10/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CLLocation+Utils.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@implementation CLLocation (Utils)

#pragma mark - Validations

- (BOOL)isValid{
    CLLocationCoordinate2D coord = self.coordinate;
    return CLLocationCoordinate2DIsValid(coord) && ((coord.latitude != 0) || (coord.longitude != 0));
}

#pragma mark - Equality

/**
 * @brief Compares values as sent to server, 6 decimal place precision, not more
 */
- (BOOL)isEqualToOtherLocation:(CLLocation *)otherLocation{
    NSString *lat1 = [NSString stringWithFormat:@"%f",self.coordinate.latitude];
    NSString *lat2 = [NSString stringWithFormat:@"%f",otherLocation.coordinate.latitude];
    NSString *lon1 = [NSString stringWithFormat:@"%f",self.coordinate.longitude];
    NSString *lon2 = [NSString stringWithFormat:@"%f",otherLocation.coordinate.longitude];
    return [lat1 isEqualToString:lat2] && [lon1 isEqualToString:lon2];
}

#pragma mark - Coordinate conversions

- (CLLocationDegrees)getHeadingToOtherCoordinate:(CLLocationCoordinate2D)otherCoord{
    CLLocationDegrees fLat = degreesToRadians(self.coordinate.latitude);
    CLLocationDegrees fLng = degreesToRadians(self.coordinate.longitude);
    CLLocationDegrees tLat = degreesToRadians(otherCoord.latitude);
    CLLocationDegrees tLng = degreesToRadians(otherCoord.longitude);
    
    CLLocationDegrees degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

- (CLLocationCoordinate2D)coordinateWithBearing:(CLLocationDegrees)bearing andDistance:(CLLocationDistance)meters{
    CLLocationDegrees distRadians = meters / (6372797.6); // earth radius in meters
    CLLocationDegrees bearingRadians = degreesToRadians(bearing);
    
    CLLocationDegrees lat1 = degreesToRadians(self.coordinate.latitude);
    CLLocationDegrees lon1 = degreesToRadians(self.coordinate.longitude);
    
    CLLocationDegrees lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians));
    CLLocationDegrees lon2 = lon1 + atan2( sin(bearingRadians) * sin(distRadians) * cos(lat1),
                                          cos(distRadians) - sin(lat1) * sin(lat2) );
    lon2 = fmod((lon2 + 3*M_PI), (2*M_PI)) - M_PI; // adjust toLonRadians to be in the range -180 to +180...
    
    CLLocationCoordinate2D target;
    target.latitude = radiansToDegrees(lat2);
    target.longitude = radiansToDegrees(lon2);
    
    return target;
}

- (CLLocationCoordinate2D)coordinateOppositeToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate{
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherCoordinate.latitude longitude:otherCoordinate.longitude];
    CLLocationDistance distance = [self distanceFromLocation:otherLocation];
    CLLocationDegrees bearing = [otherLocation getHeadingToOtherCoordinate:self.coordinate];
    
    return [self coordinateWithBearing:bearing andDistance:distance];
}

- (CLLocationCoordinate2D)middleCoordinateToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate{
    CLLocationDegrees lat = (self.coordinate.latitude +otherCoordinate.latitude)/2.0;
    CLLocationDegrees lon = (self.coordinate.longitude +otherCoordinate.longitude)/2.0;
    
    return CLLocationCoordinate2DMake(lat, lon);
}

/**
 * @param locationLiteral should have the format [lng,lat]
 */
+ (CLLocation *)locationFromString:(NSString*)locationLiteral {
    NSArray *locationComponents = [locationLiteral componentsSeparatedByString:@","];
    if (locationComponents.count == 2) {
        double lat = [[locationComponents lastObject] doubleValue];
        double lon = [[locationComponents firstObject] doubleValue];
        return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    
    return nil;
}

@end
