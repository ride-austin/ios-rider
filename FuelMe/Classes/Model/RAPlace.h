//
//  RAPlace.h
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RAPlace : NSObject <NSCoding>

@property (nonatomic, strong) NSString *shortAddress;
@property (nonatomic, strong) NSString *fullAddress;
@property (nonatomic, strong) NSString *fullAddressOneLine;
@property (nonatomic, strong) NSString *visibleAddress;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CLLocation *location;

@end

@interface RAPlace (Equality)

- (BOOL)isSimilarToPlace:(RAPlace*)otherPlace;
- (BOOL)isEqualToPlace:(RAPlace*)otherPlace;

@end

@interface RAPlace (Validation)

- (BOOL)isCoordinateValid;

@end
