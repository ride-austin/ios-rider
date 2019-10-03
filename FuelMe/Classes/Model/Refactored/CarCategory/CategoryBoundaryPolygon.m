//
//  CategoryBoundaryPolygon.h
//  Ride
//
//  Created by Roberto Abreu on 8/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CategoryBoundaryPolygon.h"

#import "GoogleMapsManager.h"
#import "RACoordinate.h"

@interface CategoryBoundaryPolygon()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic) NSArray<RACoordinate*> *boundary;

@end

@implementation CategoryBoundaryPolygon {
    GMSPath *_path;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"name" : @"name",
              @"boundary" : @"boundary"
            };
}

+ (NSValueTransformer *)boundaryJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RACoordinate.class];
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    NSArray<CLLocation *> *locations = [self.boundary valueForKey:@"location"];
    if (locations) {
        return [GMSPath coordinate:coordinate isInsidePathFromLocations:locations];
    } else {
        return YES;
    }
}

- (GMSPath *)path {
    if (!_path) {
        _path = [self pathFromBoundary];
    }
    return _path;
}
- (GMSPath *)pathFromBoundary {
    GMSMutablePath *mutablePath = [GMSMutablePath new];
    for (RACoordinate *coord in self.boundary) {
        if (CLLocationCoordinate2DIsValid(coord.coordinate)) {
            [mutablePath addCoordinate:coord.coordinate];
        }
    }
    return mutablePath;
}

@end
