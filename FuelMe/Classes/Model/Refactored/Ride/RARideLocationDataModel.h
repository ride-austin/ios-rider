//
//  RARideLocationDataModel.h
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAddress.h"
#import "RABaseDataModel.h"

@interface RARideLocationDataModel : RABaseDataModel

@property (nonatomic, strong, nullable) NSString *address;
@property (nonatomic, strong, nullable) NSString *visibleAddress;
@property (nonatomic, strong, nullable) NSString *city;
@property (nonatomic, strong, nullable) NSString *state;
@property (nonatomic, strong, nullable) NSString *zipCode;
@property (nonatomic, strong, nonnull) NSNumber *latitude;
@property (nonatomic, strong, nonnull) NSNumber *longitude;
@property (nonatomic, strong, nullable) NSDate *timestamp;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, nonnull) CLLocation *location;
@property (nonatomic, readonly, nonnull) NSString *completeAddress;

- (instancetype _Nonnull)initWithLocation:(CLLocation * _Nonnull)location;
- (instancetype _Nonnull)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (instancetype _Nonnull)initWithAddress:(RAAddress * _Nonnull)address;

- (void)setLocationByCoordinate:(CLLocationCoordinate2D)coordinate;

@end
