//
//  CLLocation+Equality.h
//  Ride
//
//  Created by Roberto Abreu on 10/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Utils)

#pragma mark - Validations
- (BOOL)isValid;

#pragma mark - Equality
- (BOOL)isEqualToOtherLocation:(CLLocation* _Nonnull)otherLocation;

#pragma mark - Coordinate Conversions
- (CLLocationDegrees)getHeadingToOtherCoordinate:(CLLocationCoordinate2D)otherCoord;
- (CLLocationCoordinate2D)coordinateWithBearing:(CLLocationDegrees)bearing andDistance:(CLLocationDistance)meters;
- (CLLocationCoordinate2D)coordinateOppositeToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate;
- (CLLocationCoordinate2D)middleCoordinateToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate;

+ (CLLocation * _Nullable)locationFromString:(NSString* _Nonnull)locationLiteral;

@end
