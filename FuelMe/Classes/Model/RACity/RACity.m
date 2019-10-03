//
//  RACity.m
//  Ride
//
//  Created by Carlos Alcala on 11/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACity.h"

#import "GoogleMapsManager.h"
#import "RACoordinate.h"
#import "UIColor+HexUtils.h"

@interface RACity()

@property (nonatomic) NSArray<RACoordinate *>*cityBoundaryPolygon;

@end

@implementation RACity

#pragma mark - Init Functions
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{@"cityID"  : @"cityId",
      @"name"    : @"cityName",
      @"imageURL": @"logoUrl",
      @"logoBlackURL": @"logoBlackUrl",
      @"cityBoundaryPolygon" : @"cityBoundaryPolygon",
      @"cityCenter" : @"cityCenterLocationData",
      };
}

+ (NSValueTransformer *)cityBoundaryPolygonJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACoordinate class]];
}

+ (NSValueTransformer *)cityCenterJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RACoordinate.class];
}

- (BOOL)isEqual:(RACity *)object {
    if ([object isKindOfClass:[RACity class]]) {
        return [self.name isEqualToString:object.name];
    } else {
        return NO;
    }
}

- (NSString *)appName {
    return [NSString stringWithFormat:@"Ride%@", self.displayName];
}

- (NSString *)displayName {
    return self.name.lowercaseString.capitalizedString;
}

- (CityType)cityType {
    if ([self.name.lowercaseString isEqualToString:@"austin"]) {
        return Austin;
    } else if ([self.name.lowercaseString isEqualToString:@"houston"]) {
        return Houston;
    }
    return Austin;
}

- (NSDictionary<NSString *, NSNumber *> *)requestParameter {
    return @{@"cityId":self.cityID};
}

- (NSString *)requestParameterString {
    return [NSString stringWithFormat:@"cityId=%@",self.cityID];
}

/**
 *  @brief shouldn't create city without cityID
 */
- (BOOL)validate:(NSError *__autoreleasing *)error {
    return [super validate:error] && self.cityID != nil;
}

@end

#pragma mark - Boundaries

@implementation RACity (Boundaries)

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    NSArray<CLLocation *> *locations = [self.cityBoundaryPolygon valueForKey:@"location"];
    if (locations) {
        return [GMSPath coordinate:coordinate isInsidePathFromLocations:locations];
    }
    else{
        return NO;
    }
}

@end
