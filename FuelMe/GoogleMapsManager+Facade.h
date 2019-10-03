//
//  GoogleMapsManager+Facade.h
//  Ride
//
//  Created by Roberto Abreu on 10/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GoogleMapsManager.h"

#import "RAActiveDriverDataModel.h"

@interface GoogleMapsManager (Facade)

@property (nonatomic, strong) NSMutableArray<NSString *> *currentNearbyCarsIdentifier;

#pragma mark - Create or Update Pin Markers
- (void)createOrUpdatePickupMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)createOrUpdateDestinationMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)addPickupTimeMarkerWithView:(UIView *)markerView toCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)createOrUpdatePrecedingTripMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark - Driver Marker
- (void)createOrUpdateDriverMarkerWithIconUrl:(NSURL *)iconUrl coordinate:(CLLocationCoordinate2D)coordinate course:(double)course;

#pragma mark - Nearby Driver Markers
- (void)showNearbyDrivers:(NSArray<RAActiveDriverDataModel*>*)drivers withCarIconUrl:(NSURL *)iconUrl;

#pragma mark - Remove Markers
- (void)removePickupMarker;
- (void)removeDestinationMarker;
- (void)removePickupTimeMarker;
- (void)removeDriverMarker;
- (void)removePrecedingTripMarker;
- (void)removeTripMarkers;
- (void)removeAllNearbyDrivers;

@end
