//
//  RAPlace.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAPlace.h"

#import "LocationService.h"

static NSString *const kPlaceShortAddressCoderKey = @"kPlaceShortAddressCoderKey";
static NSString *const kPlaceFullAddressCoderKey = @"kPlaceFullAddressCoderKey";
static NSString *const kPlaceLatitudeCoderKey = @"kPlaceLatitudeCoderKey";
static NSString *const kPlaceLongitudeCoderKey = @"kPlaceLongitudeCoderKey";
static NSString *const kPlaceZipCode = @"kPlaceZipCode";

@implementation RAPlace

- (instancetype)init {
    if (self = [super init]) {
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
    }
    return self;
}

- (NSString *)fullAddressOneLine {
    return [self.fullAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
}

#pragma mark - NSCoder

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.shortAddress = [coder decodeObjectForKey:kPlaceShortAddressCoderKey];
        self.fullAddress = [coder decodeObjectForKey:kPlaceFullAddressCoderKey];
        CLLocationDegrees lat = [coder decodeDoubleForKey:kPlaceLatitudeCoderKey];
        CLLocationDegrees lon = [coder decodeDoubleForKey:kPlaceLongitudeCoderKey];
        self.coordinate = CLLocationCoordinate2DMake(lat, lon);
        self.zipCode = [coder decodeObjectForKey:kPlaceZipCode];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.shortAddress forKey:kPlaceShortAddressCoderKey];
    [coder encodeObject:self.fullAddress forKey:kPlaceFullAddressCoderKey];
    [coder encodeDouble:self.coordinate.latitude forKey:kPlaceLatitudeCoderKey];
    [coder encodeDouble:self.coordinate.longitude forKey:kPlaceLongitudeCoderKey];
    [coder encodeObject:self.zipCode forKey:kPlaceZipCode];
}

@end

@implementation RAPlace (Equality)

- (BOOL)isSimilarToPlace:(RAPlace*)otherPlace {
    return ([self.shortAddress isEqualToString: otherPlace.shortAddress])||([self.fullAddress isEqualToString:otherPlace.fullAddress]);
}

- (BOOL)isEqualToPlace:(RAPlace*)otherPlace {
    return ((self.coordinate.latitude == otherPlace.coordinate.latitude) && (self.coordinate.longitude == otherPlace.coordinate.longitude));
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if (![other isKindOfClass:[RAPlace class]]) {
        return NO;
    } else {
        return [self isEqualToPlace:other];
    }
}

- (NSUInteger)hash {
    CLLocationDegrees lat = self.coordinate.latitude;
    if (lat < 0) {
        lat *= -1;
        lat += 91;
    }
    lat *= 100000;
    CLLocationDegrees lon = self.coordinate.longitude;
    if (lon < 0) {
        lon *= -1;
        lon += 181;
    }
    lon *= 100000;
    
    NSInteger latInt = (NSInteger)lat;
    NSInteger lonInt = (NSInteger)lon;
    
    NSInteger hash = [[NSString stringWithFormat:@"%ld%ld",(long)latInt, (long)lonInt] intValue];
    return hash;
}

@end

@implementation RAPlace (Validation)

- (BOOL)isCoordinateValid {
    return CLLocationCoordinate2DIsValid(self.coordinate) && (self.coordinate.latitude != 0) && (self.coordinate.longitude != 0);
}

@end
