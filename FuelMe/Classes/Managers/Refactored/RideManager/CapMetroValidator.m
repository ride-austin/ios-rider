//
//  CapMetroValidator.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/11/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CapMetroValidator.h"
#import "NSDictionary+JSON.h"
#import "CategoryBoundaryPolygon.h"
#import <Mantle/Mantle.h>
@interface CapMetroValidator()
@property (nonatomic) CategoryBoundaryPolygon *enfieldPolygon;
@property (nonatomic) CategoryBoundaryPolygon *westoverPolygon;
@property (nonatomic) CategoryBoundaryPolygon *tarryTownPolygon;
@end

@implementation CapMetroValidator

// MARK: Internal

- (CategoryBoundaryPolygon *)enfieldPolygon {
    if (!_enfieldPolygon) {
        id jsonEnfield = [NSDictionary jsonFromResourceName:@"Enfield"];
        _enfieldPolygon = [MTLJSONAdapter modelOfClass:CategoryBoundaryPolygon.class fromJSONDictionary:jsonEnfield error:nil];
    }
    return _enfieldPolygon;
}

- (CategoryBoundaryPolygon *)westoverPolygon {
    if (!_westoverPolygon) {
        id jsonWestover = [NSDictionary jsonFromResourceName:@"Westover"];
        _westoverPolygon = [MTLJSONAdapter modelOfClass:CategoryBoundaryPolygon.class fromJSONDictionary:jsonWestover error:nil];
    }
    return _westoverPolygon;
}

- (CategoryBoundaryPolygon *)tarryTownPolygon {
    if (!_tarryTownPolygon) {
        id jsonTarryTown = [NSDictionary jsonFromResourceName:@"TarryTown"];
        _tarryTownPolygon = [MTLJSONAdapter modelOfClass:CategoryBoundaryPolygon.class fromJSONDictionary:jsonTarryTown error:nil];
    }
    return _tarryTownPolygon;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isValidStart:(CLLocationCoordinate2D)startCoordinate andEndCoordinate:(CLLocationCoordinate2D)endCoordinate {
    if ([self.tarryTownPolygon containsCoordinate:startCoordinate]) {
        if ([self.tarryTownPolygon containsCoordinate:endCoordinate]) {
            return NO;
        }
        if ([self.westoverPolygon containsCoordinate:endCoordinate] || [self.enfieldPolygon containsCoordinate:endCoordinate]) {
            return YES;
        }
    }
    
    if ([self.tarryTownPolygon containsCoordinate:endCoordinate]) {
        if ([self.westoverPolygon containsCoordinate:startCoordinate] || [self.enfieldPolygon containsCoordinate:startCoordinate]) {
            return YES;
        }
    }
    return NO;
}
@end
