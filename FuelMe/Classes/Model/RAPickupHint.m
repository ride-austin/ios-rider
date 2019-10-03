//
//  RAPickupHint.m
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPickupHint.h"

#import "GoogleMapsManager.h"

@interface RAPickupHint() {
    GMSPath *_path;
}
@end

@implementation RAPickupHint

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"name" : @"name",
              @"areaPolygon" : @"areaPolygon",
              @"designatedPickups" : @"designatedPickups"
              };
}

+ (NSValueTransformer *)areaPolygonJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACoordinate class]];
}

+ (NSValueTransformer *)designatedPickupsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RADesignatedPickup class]];
}

- (GMSPath *)path {
    if (!_path) {
        NSArray<CLLocation *> *locations = [self.areaPolygon valueForKey:@"location"];
        if (locations) {
            _path = [GMSPath pathWithLocations:locations];
        }
    }
    return _path;
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    return [GMSPath coordinate:coordinate isInsidePath:self.path];
}

@end
