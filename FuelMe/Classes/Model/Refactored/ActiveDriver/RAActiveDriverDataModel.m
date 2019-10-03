//
//  RAActiveDriverDataModel.m
//  RideAustin
//
//  Created by Kitos on 2/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAActiveDriverDataModel.h"

@interface RAActiveDriverDataModel ()

@property (nonatomic) BOOL needsNewLocation;
@property (nonatomic, strong) CLLocation *location;

@end

@interface RAActiveDriverDataModel (Private)

- (CLLocation*)getLocation;

@end

@implementation RAActiveDriverDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RAActiveDriverDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"status" : @"status",
             @"driver" : @"driver",
             @"currentZipCode" : @"currentZipCode",
             @"heading" : @"heading",
             @"course" : @"course",
             @"speed" : @"speed",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"timeToReachRider" : @"drivingTimeToRider",
             @"distanceToReachRider" : @"drivingDistanceToRider",
             @"selectedCar" : @"selectedCar"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        // if server sends null
        if (!self.course || ![self.course isKindOfClass:[NSNumber class]]) {
            self.course = [NSNumber numberWithDouble:0.0];
        }
        if (!self.speed || ![self.speed isKindOfClass:[NSNumber class]]) {
            self.speed = [NSNumber numberWithDouble:0.0];
        }
    }
    return self;
}

- (CLLocation *)location {
    if (!_location) {
        _location = [self getLocation];
    }
    return _location;
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)driverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RADriverDataModel.class];
}

+ (NSValueTransformer *)selectedCarJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RACarDataModel.class];
}

#pragma mark - Model Protocol

- (BOOL)needsSpecialComparisonForProperty:(NSString *)name {
    return ([@[@"latitude",@"longitude"] containsObject:name]);
}

- (BOOL)shouldUpdateProperty:(NSString *)name usingSpecialComparisonWithNewValue:(id)value {
    if ([name isEqualToString:@"latitude"]) {
        return ![RABaseDataModel rideDegrees:self.latitude.doubleValue isEqualToOtherRideDegrees:((NSNumber*)value).doubleValue];
    } else if ([name isEqualToString:@"longitude"]){
        return ![RABaseDataModel rideDegrees:self.longitude.doubleValue isEqualToOtherRideDegrees:((NSNumber*)value).doubleValue];
    } else {
        return YES;
    }
}

- (void)didUpdatePropertyWithName:(NSString *)name fromModel:(RABaseDataModel *)model {
    self.needsNewLocation = self.needsNewLocation
                            || [name isEqualToString:@"speed"]
                            || [name isEqualToString:@"course"]
                            || [name isEqualToString:@"heading"]
                            || [name isEqualToString:@"latitude"]
                            || [name isEqualToString:@"longitude"];
}

- (void)didFinishUpdatingWithModel:(RABaseDataModel *)model {
    if (self.needsNewLocation) {
        self.location = [self getLocation];
        self.needsNewLocation = NO;
    }
}

@end

#pragma mark - Private

@implementation RAActiveDriverDataModel (Private)

- (CLLocation *)getLocation {
    return [[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)
                                        altitude:0
                              horizontalAccuracy:0
                                verticalAccuracy:0
                                          course:self.course.doubleValue
                                           speed:self.speed.doubleValue
                                       timestamp:[NSDate date]
     ];
}

@end
