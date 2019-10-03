//
//  GoogleMapsManager.h
//  Ride
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

extern NSString * _Nonnull const kInvalidRouteCoordinateErrorDomain;

@interface GoogleMapsManager : NSObject

@property (nonatomic, readonly) GMSMapView * _Nonnull mapView;

- (instancetype _Nonnull)initWithMap:(GMSMapView* _Nonnull)mapView;

@end

@interface GoogleMapsManager (Map)

- (void)showMyLocation:(BOOL)show;
- (void)setPadding:(UIEdgeInsets)padding;
- (UIEdgeInsets)getPadding;
- (CLLocation* _Nullable)getMyCurrentLocation;

@end

@interface GoogleMapsManager (Markers)

- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex rotation:(CLLocationDegrees)rotation groundAnchor:(CGPoint)groundAnchor;
- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex;
- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:( NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon;
- (void)addMarker:(GMSMarker* _Nonnull)marker withIdentifier:(NSString* _Nonnull)identifier toCoordinates:(CLLocationCoordinate2D)coords;
- (void)updateMarkerWithIdentifier:(NSString* _Nonnull)identifier toPosition:(CLLocationCoordinate2D)coords;
- (void)removeMarkerWithIdentifier:(NSString* _Nonnull)identifier;
- (GMSMarker* _Nullable)markerWithIdentifier:(NSString* _Nonnull)identifier;

@end

@interface GoogleMapsManager (Camera)

- (void)animateToLocation:(CLLocationCoordinate2D)coordinate;
- (void)animateToZoom:(float)zoom;
- (void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate zoom:(float)zoomLevel;
- (void)animateCameraToFitStartCoordinate:(CLLocationCoordinate2D)start endCoordinate:(CLLocationCoordinate2D)end withEdgeInsets:(UIEdgeInsets)insets;
- (void)animateCameraToFitBounds:(GMSCoordinateBounds* _Nonnull)bounds withEdgeInsets:(UIEdgeInsets)insets;

@end

@interface GoogleMapsManager (Route)

- (void)getRouteFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to waypoints:(NSArray<CLLocation *> *_Nullable)waypoints completion:( void (^ _Nullable)(GMSPolyline* _Nullable polyline, GMSCoordinateBounds* _Nullable bounds, NSError* _Nullable error) )handler;

- (void)drawRoute:(GMSPolyline* _Nonnull)route withIdentifier:(NSString* _Nonnull)identifier;
- (void)eraseRouteWithIdentifier:(NSString* _Nonnull)identifier;

- (GMSCoordinateBounds * _Nullable)boundsForRouteWithIdentifier:(NSString* _Nonnull)identifier;

@end

@interface GMSPath (Utils)

+ (GMSPath* _Nonnull)pathWithLocations:(NSArray<CLLocation*> * _Nonnull)locations;
+ (BOOL) location:(CLLocation* _Nonnull)location isInsidePath:(GMSPath* _Nonnull)path;
+ (BOOL) location:(CLLocation* _Nonnull)location isInsidePathFromLocations:(NSArray<CLLocation*> * _Nonnull)locations;
+ (BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePath:(GMSPath *)path;
+ (BOOL) coordinate:(CLLocationCoordinate2D)coordinate isInsidePathFromLocations:(NSArray<CLLocation*> * _Nonnull)locations;

@end
