//
//  GoogleMapsManager.m
//  Ride
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "GoogleMapsManager.h"
#import "AppConfig.h"
#import "CLLocation+Utils.h"
#import "ErrorReporter.h"

#define kGoogleAPIDirectionsBaseUrl @"https://maps.googleapis.com/maps/api/directions/json"
@interface GoogleMapsManager ()

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSMarker*> *markers;
@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSPolyline*> *routes;

@end

@interface GMSPath (Span)

- (GMSCoordinateBounds*)spanBounds;

@end

@implementation GoogleMapsManager

- (instancetype)initWithMap:(GMSMapView *)mapView {
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.mapView.paddingAdjustmentBehavior = kGMSMapViewPaddingAdjustmentBehaviorAlways;
    }
    return self;
}

@end

#pragma mark - Map

@implementation GoogleMapsManager (Map)

- (void)showMyLocation:(BOOL)show {
    if (show) {
        CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
        self.mapView.myLocationEnabled = locationAuthorizationStatus == kCLAuthorizationStatusAuthorizedAlways || locationAuthorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
    } else {
        #ifdef TEST
        self.mapView.myLocationEnabled = YES;
        #else
        self.mapView.myLocationEnabled = NO;
        #endif
    }
}

- (void)setPadding:(UIEdgeInsets)padding{
    self.mapView.padding = padding;
}

- (UIEdgeInsets)getPadding{
    return self.mapView.padding;
}

- (CLLocation*)getMyCurrentLocation {
    return self.mapView.myLocation;
}

@end

#pragma mark - Markers

@implementation GoogleMapsManager (Markers)

- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex rotation:(CLLocationDegrees)rotation groundAnchor:(CGPoint)groundAnchor {
    GMSMarker *marker = [GMSMarker markerWithPosition:coords];
    marker.icon = icon;
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.zIndex = zIndex;
    marker.rotation = rotation;
    marker.groundAnchor = groundAnchor;
    [self addMarker:marker withIdentifier:identifier toCoordinates:coords];
    
#ifdef AUTOMATION
    marker.accessibilityElementsHidden = NO;
    marker.accessibilityLabel = identifier;
#endif
}

- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex {
    [self addMarkerToCoordinates:coords withIdentifier:identifier icon:icon zIndex:zIndex rotation:0 groundAnchor:CGPointMake(0.5, 1.0)];
}

- (void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString *)identifier icon:(UIImage *)icon{
    [self addMarkerToCoordinates:coords withIdentifier:identifier icon:icon zIndex:0];
}

- (void)addMarker:(GMSMarker *)marker withIdentifier:(NSString *)identifier toCoordinates:(CLLocationCoordinate2D)coords{
    [self removeMarkerWithIdentifier:identifier];
    if (self.markers) {
        self.markers[identifier] = marker;
    } else {
        self.markers = [NSMutableDictionary dictionaryWithObject:marker forKey:identifier];
    }
}

- (void)updateMarkerWithIdentifier:(NSString * _Nonnull)identifier toPosition:(CLLocationCoordinate2D)coords {
    GMSMarker *marker = [self.markers objectForKey:identifier];
    if (marker) {
        marker.position = coords;
    }
}

- (void)removeMarkerWithIdentifier:(NSString *)identifier {
    GMSMarker *marker = self.markers[identifier];
    marker.map = nil;
    [self.markers removeObjectForKey:identifier];
}

- (GMSMarker*)markerWithIdentifier:(NSString*)identifier {
    return self.markers[identifier];
}

@end

#pragma mark - Camera

@implementation GoogleMapsManager (Camera)

- (void)animateToLocation:(CLLocationCoordinate2D)coordinate {
    [self.mapView animateToLocation:coordinate];
}

- (void)animateToZoom:(float)zoom {
    [self.mapView animateToZoom:zoom];
}

- (void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate {
    [self animateCameraToCoordinate:coordinate zoom:self.mapView.camera.zoom];
}

- (void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate zoom:(float)zoomLevel {
    GMSCameraPosition *camPos = [GMSCameraPosition cameraWithTarget:coordinate zoom:zoomLevel];
    [self.mapView animateToCameraPosition:camPos];
}

- (void)animateCameraToFitStartCoordinate:(CLLocationCoordinate2D)start endCoordinate:(CLLocationCoordinate2D)end withEdgeInsets:(UIEdgeInsets)insets {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:start coordinate:end];
    [self animateCameraToFitBounds:bounds withEdgeInsets:insets];
}

- (void)animateCameraToFitBounds:(GMSCoordinateBounds *)bounds withEdgeInsets:(UIEdgeInsets)insets {
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:insets]];
}

@end

#pragma mark - Route

NSString *const kInvalidRouteCoordinateErrorDomain = @"com.rideaustin.route.error";

@implementation GoogleMapsManager (Route)

- (NSString *)waypointsQueryFromLocation:(NSArray<CLLocation *> *)waypoints {
    NSMutableString *waypointsQuery;
    for (CLLocation *waypointLocation in waypoints) {
        if ([waypointLocation isValid]) {
            if (waypointsQuery) {
                [waypointsQuery appendString:@"|"];
            }
            
            if (!waypointsQuery) {
                waypointsQuery = [[NSMutableString alloc] initWithString:@"waypoints="];
            }
            
            CLLocationCoordinate2D coordinate = waypointLocation.coordinate;
            [waypointsQuery appendFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
        }
    }
    return waypointsQuery;
}

- (void)getRouteFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to waypoints:(NSArray<CLLocation *> *)waypoints completion:(void (^)(GMSPolyline * _Nullable, GMSCoordinateBounds * _Nullable, NSError * _Nullable))handler {
    
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:to.latitude longitude:to.longitude];
    
    if ([fromLocation isValid] && [toLocation isValid]) {
        NSString *origin = [NSString stringWithFormat:@"origin=%f,%f", from.latitude, from.longitude];
        NSString *destin = [NSString stringWithFormat:@"destination=%f,%f", to.latitude, to.longitude];
        NSString *sensor = @"sensor=false";
        NSString *mode   = @"mode=driving";
        NSString *key  = [NSString stringWithFormat:@"key=%@", [AppConfig googleDirectionsKey]];
        NSString *path = [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@", kGoogleAPIDirectionsBaseUrl, origin, destin, sensor, mode, key];

        NSString *waypointsQuery = [self waypointsQueryFromLocation:waypoints];
        if (waypointsQuery) {
            path = [NSString stringWithFormat:@"%@&%@", path, waypointsQuery];
        }
        
        NSURL *url = [[NSURL alloc] initWithString:path];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [ErrorReporter recordError:error withDomainName:GOOGLEGetRoute];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, nil, error);
                });
            } else {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *routes = [json objectForKey:@"routes"];
                NSDictionary *routeJson = [routes firstObject];
                NSDictionary *routeOverviewPolyline = [routeJson objectForKey:@"overview_polyline"];
                NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                
                GMSPath *path = [GMSPath pathFromEncodedPath:points];
                GMSCoordinateBounds *bounds = [path spanBounds];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                    handler(polyline, bounds,nil);
                });
            }
        }] resume];
        
    } else {
        NSError *error = [NSError errorWithDomain:kInvalidRouteCoordinateErrorDomain code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat: @"Invalid coordinates[from:(%f,%f) - to:(%f,%f)]",from.latitude,from.longitude,to.latitude,to.longitude]}];
        [ErrorReporter recordErrorDomainName:GOOGLEGetRoute withUserInfo:@{@"logs":[NSString stringWithFormat: @"Invalid coordinates[from:(%f,%f) - to:(%f,%f)]",from.latitude,from.longitude,to.latitude,to.longitude]}];
        handler(nil, nil, error);
    }
    
}

- (void)drawRoute:(GMSPolyline *)route withIdentifier:(NSString *)identifier {
    if (!self.routes) {
        self.routes = [[NSMutableDictionary alloc] init];
    }
    
    if (self.routes[identifier]) {
        GMSPolyline *cachedRoute = self.routes[identifier];
        cachedRoute.path = route.path;
        cachedRoute.strokeColor = route.strokeColor;
        cachedRoute.strokeWidth = route.strokeWidth;
    } else {
        route.map = self.mapView;
        self.routes[identifier] = route;
    }
}

- (void)eraseRouteWithIdentifier:(NSString *)identifier {
    GMSPolyline *route = self.routes[identifier];
    if (route) {
        route.map = nil;
        [self.routes removeObjectForKey:identifier];
    }
}

- (GMSCoordinateBounds *)boundsForRouteWithIdentifier:(NSString *)identifier {
    GMSPolyline *route = self.routes[identifier];
    if (route) {
        return route.path.spanBounds;
    }
    return nil;
}

@end


#pragma mark - GMSPath

#pragma mark - Utils

@implementation GMSPath (Utils)

+ (GMSPath *)pathWithLocations:(NSArray<CLLocation *> *)locations {
    GMSMutablePath *mPath = [[GMSMutablePath alloc] init];
    for (CLLocation *location in locations) {
        [mPath addCoordinate:location.coordinate];
    }
    return [[GMSPath alloc] initWithPath:mPath];
}

+ (BOOL)location:(CLLocation *)location isInsidePath:(GMSPath *)path {
    return [self coordinate:location.coordinate isInsidePath:path];
}

+ (BOOL)location:(CLLocation *)location isInsidePathFromLocations:(NSArray<CLLocation *> *)locations {
    return [self coordinate:location.coordinate isInsidePathFromLocations:locations];
}

+ (BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePath:(GMSPath *)path {
    return GMSGeometryContainsLocation(coordinate, path, YES);
}

+ (BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePathFromLocations:(NSArray<CLLocation *> *)locations {
    GMSPath *path = [self pathWithLocations:locations];
    return [GMSPath coordinate:coordinate isInsidePath:path];
}

@end

#pragma mark Span

@implementation GMSPath (Span)

- (GMSCoordinateBounds *)spanBounds {
    if (self.count > 0) {
        
        CLLocationDegrees minLat;
        CLLocationDegrees minLon;
        CLLocationDegrees maxLat;
        CLLocationDegrees maxLon;
        
        CLLocationCoordinate2D coord = [self coordinateAtIndex:0];
        
        minLat = coord.latitude;
        minLon = coord.longitude;
        maxLat = coord.latitude;
        maxLon = coord.longitude;
        
        for (NSInteger i = 1; i<self.count; i++) {
            coord = [self coordinateAtIndex:i];
            
            if (coord.latitude < minLat) {
                minLat = coord.latitude;
            }
            if (coord.longitude < minLon) {
                minLon = coord.longitude;
            }
            if (coord.latitude > maxLat) {
                maxLat = coord.latitude;
            }
            if (coord.longitude > maxLon) {
                maxLon = coord.longitude;
            }
        }
        
        CLLocationCoordinate2D minCoord = CLLocationCoordinate2DMake(minLat, minLon);
        CLLocationCoordinate2D maxCoord = CLLocationCoordinate2DMake(maxLat, maxLon);
        
        return [[GMSCoordinateBounds alloc] initWithCoordinate:minCoord coordinate:maxCoord];
    }
    
    return nil;
}

@end
