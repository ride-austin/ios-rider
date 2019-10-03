//
//  LocationService.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 1/31/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLLocation+isValid.h"
#import "RARideStatus.h"

#import <GoogleMaps/GoogleMaps.h>

typedef void(^LocationResult)(CLLocation* _Nullable location,NSError* _Nullable error);

extern NSString* const kLocationServiceHasLatlng;
extern NSString* const kLocationServiceHasHeading;
extern NSString* const kLocationAuthorizationStatusChanged;

@interface LocationService : NSObject<CLLocationManagerDelegate>

@property(nonatomic, strong, nonnull) CLLocationManager* locationManager;
@property(atomic, strong, nullable) CLLocation* myLocation;
@property(nonatomic) CLLocationDirection myDirection;
@property(nonatomic) double elevation;

+ (LocationService* _Nonnull)sharedService;

- (void)stop;
- (void)start;
- (void)getMyCurrentLocationWithCompleteBlock:(LocationResult _Nullable)completeBlock;
+ (CLLocation * _Nullable)myValidLocation;
+ (void)getLocationBasedOnIPAddressWithCompletion:(LocationResult _Nullable)completeBlock;

@end

@interface LocationService (SettingsBasedOnRide)

- (void)updateLocationSettingsForStatus:(RARideStatus)status;

@end

