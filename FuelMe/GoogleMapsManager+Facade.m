//
//  GoogleMapsManager+Facade.m
//  Ride
//
//  Created by Roberto Abreu on 10/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GoogleMapsManager+Facade.h"

#import <objc/runtime.h>

#import <SDWebImage/UIImageView+WebCache.h>


//zIndex Markers
#define routeZIndex 1
#define carZIndex 2
#define precedingTripMarkerZIndex 3
#define pinZIndex 4
#define pinPickupTimeZIndex 5

//Marker Identifieres
#define kPickupMarker @"startLocationMarker"
#define kDestinationMarker @"endLocationMarker"
#define kPickupTimeMarker @"pickupTimeMarker"
#define kDriverMarker @"driverMarker"
#define kNearbyCar @"nearbyCar"
#define kActiveRoute @"kActiveRouteIdentifier"
#define kPrecedingTripMarker @"precedingTripMarker"

@implementation GoogleMapsManager (Facade)

#pragma mark - Create or Update Pin Markers

- (void)createOrUpdatePickupMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self markerWithIdentifier:kPickupMarker]) {
        [self updateMarkerWithIdentifier:kPickupMarker toPosition:coordinate];
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kPickupMarker icon:[UIImage imageNamed:@"green-pin"] zIndex:pinZIndex rotation:0 groundAnchor:CGPointMake(0.5, 0.8)];
    }
}

- (void)createOrUpdateDestinationMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self markerWithIdentifier:kDestinationMarker]) {
        [self updateMarkerWithIdentifier:kDestinationMarker toPosition:coordinate];
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kDestinationMarker icon:[UIImage imageNamed:@"red-pin"] zIndex:pinZIndex rotation:0 groundAnchor:CGPointMake(0.5, 0.8)];
    }
}

- (void)addPickupTimeMarkerWithView:(UIView *)markerView toCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self markerWithIdentifier:kPickupTimeMarker]) {
        [self updateMarkerWithIdentifier:kPickupTimeMarker toPosition:coordinate];
    } else {
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        marker.iconView = markerView;
        marker.zIndex = pinPickupTimeZIndex;
        marker.map = self.mapView;
        [self addMarker:marker withIdentifier:kPickupTimeMarker toCoordinates:coordinate];
    }
}

- (void)createOrUpdatePrecedingTripMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self markerWithIdentifier:kPrecedingTripMarker]) {
        [self updateMarkerWithIdentifier:kPrecedingTripMarker toPosition:coordinate];
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kPrecedingTripMarker icon:[UIImage imageNamed:@"preceding-trip-marker-icon"] zIndex:precedingTripMarkerZIndex];
    }
}

#pragma mark - Driver Marker

- (void)createOrUpdateDriverMarkerWithIconUrl:(NSURL *)iconUrl coordinate:(CLLocationCoordinate2D)coordinate course:(double)course {
    GMSMarker *driverMarker = [self markerWithIdentifier:kDriverMarker];
    if (driverMarker) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:2.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [driverMarker setRotation:course];
        [driverMarker setPosition:coordinate];
        [CATransaction commit];
    } else {
        UIImageView *ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 48)];
        ivIcon.contentMode = UIViewContentModeScaleAspectFit;
        [ivIcon sd_setImageWithURL:iconUrl placeholderImage:[UIImage imageNamed:@"car"]];
        
        driverMarker = [GMSMarker markerWithPosition:coordinate];
        driverMarker.rotation = course;
        driverMarker.groundAnchor = CGPointMake(.5, .5);
        driverMarker.iconView = ivIcon;
        driverMarker.appearAnimation = kGMSMarkerAnimationPop;
        driverMarker.map = self.mapView;
        [self addMarker:driverMarker withIdentifier:kDriverMarker toCoordinates:coordinate];
    }
}

#pragma mark - Nearby Driver Markers

- (void)setCurrentNearbyCarsIdentifier:(NSMutableArray<NSString *> *)currentNearbyCarsIdentifier {
    objc_setAssociatedObject(self, @selector(currentNearbyCarsIdentifier), currentNearbyCarsIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<NSString *> *)currentNearbyCarsIdentifier {
    return objc_getAssociatedObject(self, @selector(currentNearbyCarsIdentifier));
}

- (void)showNearbyDrivers:(NSArray<RAActiveDriverDataModel*>*)drivers withCarIconUrl:(NSURL *)iconUrl {
    if (!self.currentNearbyCarsIdentifier) {
        self.currentNearbyCarsIdentifier = [[NSMutableArray alloc] init];
    }
    
    //Clear Active Drivers
    for (NSString *nearbyCarIdentifier in self.currentNearbyCarsIdentifier) {
        [self removeMarkerWithIdentifier:nearbyCarIdentifier];
    }
    
    NSMutableArray<NSString*> *tmpCurrentNearbyCarsIdentifiers = [[NSMutableArray alloc] init];
    for (RAActiveDriverDataModel *activeDriver in drivers) {
        NSNumber *userId = activeDriver.driver.user.modelID;
        
        if (!userId) {
            continue;
        }
        
        NSString *nearbyCarIdentifier = [NSString stringWithFormat:@"%@-%@", kNearbyCar, userId.stringValue];
        
        UIImageView *ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 48)];
        ivIcon.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *defaultCarIcon = [UIImage imageNamed:@"car"];
        [ivIcon sd_setImageWithURL:iconUrl placeholderImage:defaultCarIcon];
        
        GMSMarker *nearbyCar = [GMSMarker markerWithPosition:activeDriver.location.coordinate];
        nearbyCar.groundAnchor = CGPointMake(.5, .5);
        nearbyCar.iconView = ivIcon;
        nearbyCar.rotation = activeDriver.course.doubleValue;
        nearbyCar.zIndex = carZIndex;
        nearbyCar.map = self.mapView;
        
#ifdef AUTOMATION
        nearbyCar.accessibilityElementsHidden = NO;
        nearbyCar.accessibilityValue = [NSString stringWithFormat:@"DRIVER:%@",nearbyCarIdentifier];
        nearbyCar.accessibilityLabel = [NSString stringWithFormat:@"DRIVER:%@",nearbyCarIdentifier];
#endif
        [self addMarker:nearbyCar withIdentifier:nearbyCarIdentifier toCoordinates:activeDriver.location.coordinate];
        
        [tmpCurrentNearbyCarsIdentifiers addObject:nearbyCarIdentifier];
    }
    
    self.currentNearbyCarsIdentifier = tmpCurrentNearbyCarsIdentifiers;
}

#pragma mark - Remove Markers

- (void)removePickupMarker {
    [self removeMarkerWithIdentifier:kPickupMarker];
}

- (void)removeDestinationMarker {
    [self removeMarkerWithIdentifier:kDestinationMarker];
}

- (void)removePickupTimeMarker {
    [self removeMarkerWithIdentifier:kPickupTimeMarker];
}

- (void)removeDriverMarker {
    [self removeMarkerWithIdentifier:kDriverMarker];
}

- (void)removePrecedingTripMarker {
    [self removeMarkerWithIdentifier:kPrecedingTripMarker];
}

- (void)removeTripMarkers {
    [self removePickupMarker];
    [self removeDestinationMarker];
    [self removePickupTimeMarker];
    [self removeDriverMarker];
    [self removePrecedingTripMarker];
    [self eraseRouteWithIdentifier:kActiveRoute];
}

- (void)removeAllNearbyDrivers {
    for (NSString *nearbyCarIdentifier in self.currentNearbyCarsIdentifier) {
        [self removeMarkerWithIdentifier:nearbyCarIdentifier];
    }
    [self.currentNearbyCarsIdentifier removeAllObjects];
}

@end
