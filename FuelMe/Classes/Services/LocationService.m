//
//  LocationService.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 1/31/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "LocationService.h"
#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "IPAddress.h"
#import "RAMacros.h"
#import "RARideAPI.h"
#import "RARideManager.h"
#import "RASessionManager.h"
#import "SystemVersionCompare.h"

#import <CoreLocation/CoreLocation.h>

NSString *const kLocationServiceHasLatlng = @"kLocationServiceHasLatlng";
NSString *const kLocationServiceHasHeading = @"kLocationServiceHasHeading";
NSString *const kLocationAuthorizationStatusChanged = @"kLocationAuthorizationStatusChanged";

@interface LocationService()

@property (nonatomic, strong) NSDate *lastBackgroundLocationUpdate;
@property (nonatomic, copy) LocationResult locationResultCompletionBlock;

@end

@interface LocationService(BackgroundUpdates)

- (void)updateBackgroundLocationSettingsForStatus:(RARideStatus)status;
- (void)sendRiderLocationWhenInBackground;

@end

@implementation LocationService

#pragma mark - Initializer

+ (LocationService*)sharedService {
    static LocationService *locationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationService = [[self alloc] init];
    });
    return locationService;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        [_locationManager requestWhenInUseAuthorization];
    }
    return self;
}

#pragma mark - Service Methods

- (void)start {
    [self.locationManager startUpdatingLocation];
    if ([CLLocationManager headingAvailable]) {
        [self.locationManager startUpdatingHeading];
    }
}

- (void)stop {
    [self.locationManager stopUpdatingLocation];
    if ([CLLocationManager headingAvailable]) {
        [self.locationManager stopUpdatingHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DBLog(@"Error in location: %@", [error localizedDescription]);
    if (self.locationResultCompletionBlock) {
        self.locationResultCompletionBlock(nil,error);
        self.locationResultCompletionBlock = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];

    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    self.myLocation = newLocation;
    
    [self sendRiderLocationWhenInBackground];
    
    if (self.locationResultCompletionBlock) {
        self.locationResultCompletionBlock(newLocation,nil);
        self.locationResultCompletionBlock = nil;
    } else {
        [self sendNotification:kLocationServiceHasLatlng];
    }
    [ConfigurationManager checkConfigurationBasedOnLocation:newLocation];
}


- (void)getMyCurrentLocationWithCompleteBlock:(LocationResult)completeBlock{
    self.locationResultCompletionBlock = completeBlock;
    [self start];
}

- (void)notifyMainThead:(NSString*)notficationName {
    [[NSNotificationCenter defaultCenter] postNotificationName:notficationName object:nil];
}

- (void)sendNotification:(NSString*)notficationName {
    [self performSelectorOnMainThread:@selector(notifyMainThead:) withObject:notficationName waitUntilDone:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
    return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.myDirection = theHeading;
    [self sendNotification:kLocationServiceHasHeading];
}

/**
 *  if location is authorized, then configuration will be loaded when location update is received
 *  if location is not authorized, get location from IPAddress
 *  if not determined, do nothing
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [ConfigurationManager checkConfigurationBasedOnLocation:nil];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [ConfigurationManager needsReload];
            break;
    }
    [self sendNotification:kLocationAuthorizationStatusChanged];
}

+ (CLLocation *)myValidLocation {
    CLLocation *myLocation = [self sharedService].myLocation;
    if (myLocation && [CLLocation isCoordinateNonZero:myLocation.coordinate]) {
        return myLocation;
    }
    return nil;
}

+ (void)getLocationBasedOnIPAddressWithCompletion:(LocationResult)completeBlock {
    NSString *path = @"http://ip-api.com/json";
    [[RARequest requestWithPath:path success:^(NSURLSessionTask *networkTask, id response) {
        NSError *error = nil;
        IPAddress *address = [MTLJSONAdapter modelOfClass:[IPAddress class] fromJSONDictionary:response error:&error];
        [ErrorReporter recordError:error withDomainName:GETIPAddress];
        if (completeBlock) {
            completeBlock(address.location,error);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }] execute];
}

@end

@implementation LocationService (BackgroundUpdates)

- (void)updateBackgroundLocationSettingsForStatus:(RARideStatus)rideStatus {
    self.locationManager.pausesLocationUpdatesAutomatically = ![self isLocationNeededInBackgroundForStatus:rideStatus];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.locationManager.allowsBackgroundLocationUpdates = [self isLocationNeededInBackgroundForStatus:rideStatus];
    }
}

- (BOOL)isLocationNeededInBackgroundForStatus:(RARideStatus)rideStatus {
    switch (rideStatus) {
        case RARideStatusUnknown:
        case RARideStatusNone:
        case RARideStatusPrepared:
        case RARideStatusNoAvailableDriver:
        case RARideStatusRiderCancelled:
        case RARideStatusDriverCancelled:
        case RARideStatusAdminCancelled:
        case RARideStatusCompleted:
            return NO;
            
        case RARideStatusRequesting:
        case RARideStatusRequested:
        case RARideStatusDriverAssigned:
        case RARideStatusDriverReached:
        case RARideStatusActive:
            return YES;
    }
}

- (void)sendRiderLocationWhenInBackground {
    CLLocation *newLocation = self.myLocation;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        RARideDataModel *currentRide = [RARideManager sharedManager].currentRide;
        if ([RASessionManager sharedManager].isSignedIn && [self isLocationNeededInBackgroundForStatus:currentRide.status]) {
            NSString *rideID = currentRide.modelID.stringValue;
            ConfigLiveLocation *config = [ConfigurationManager shared].global.liveLocation;
            if ([newLocation shouldUpdateBasedOnConfig:config andLastUpdate:self.lastBackgroundLocationUpdate]) {
                [RARideAPI getRide:rideID withRiderLocation:newLocation andCompletion:^(RARideDataModel *ride, NSError *error) {
                    if (error == nil) {
                        self.lastBackgroundLocationUpdate = newLocation.timestamp;
                        [currentRide updateChanges:ride];
                    }
                }];
            }
        }
    }
}

@end

@implementation LocationService (SettingsBasedOnRide)

- (void)updateLocationSettingsForStatus:(RARideStatus)rideStatus {
    [self updateAccuracyForStatus:rideStatus];
    [self updateBackgroundLocationSettingsForStatus:rideStatus];
}

- (void)updateAccuracyForStatus:(RARideStatus)rideStatus {
    BOOL needsHighAccuracy = [self isAccurateLocationNeededForStatus:rideStatus];
    self.locationManager.distanceFilter  = needsHighAccuracy ? kCLDistanceFilterNone : 8;
    self.locationManager.desiredAccuracy = needsHighAccuracy ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest;
}

- (BOOL)isAccurateLocationNeededForStatus:(RARideStatus)rideStatus {
    switch (rideStatus) {
        case RARideStatusUnknown:
        case RARideStatusNone:
        case RARideStatusPrepared:
        case RARideStatusNoAvailableDriver:
        case RARideStatusRiderCancelled:
        case RARideStatusDriverCancelled:
        case RARideStatusAdminCancelled:
        case RARideStatusActive:
        case RARideStatusCompleted:
            return NO;
            
        case RARideStatusRequesting:
        case RARideStatusRequested:
        case RARideStatusDriverAssigned:
        case RARideStatusDriverReached:
            return YES;
    }
}

@end
