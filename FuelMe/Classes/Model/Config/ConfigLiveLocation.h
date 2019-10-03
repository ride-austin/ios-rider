//
//  ConfigLiveLocation.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigLiveLocation : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) NSNumber *expirationTime;
@property (nonatomic, readonly) NSNumber *requiredAccuracy;

@end

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (ValidLiveLocation)

- (BOOL)isValidLiveLocationBasedOnConfig:(ConfigLiveLocation *)config;

/**
 if live location is enabled, allow to update location 1 second before expiration to avoid excessive calls
 */
- (BOOL)shouldUpdateBasedOnConfig:(ConfigLiveLocation*)config andLastUpdate:(NSDate *)lastLocationUpdate;

@end
