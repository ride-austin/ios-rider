//
//  RAPrecedingRideDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 1/29/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAPrecedingRideDataModel.h"

#import "RARideLocationDataModel.h"

@implementation RAPrecedingRideDataModel

#pragma mark - JSONKeyPaths Mapping

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"status": @"status",
             @"endLocation": @"end",
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)statusJSONTransformer{
    NSDictionary *statuses = @{
                               @"REQUESTED": @(RARideStatusRequested),
                               @"NO_AVAILABLE_DRIVER": @(RARideStatusNoAvailableDriver),
                               @"RIDER_CANCELLED": @(RARideStatusRiderCancelled),
                               @"DRIVER_CANCELLED": @(RARideStatusDriverCancelled),
                               @"ADMIN_CANCELLED": @(RARideStatusAdminCancelled),
                               @"DRIVER_ASSIGNED": @(RARideStatusDriverAssigned),
                               @"DRIVER_REACHED": @(RARideStatusDriverReached),
                               @"ACTIVE": @(RARideStatusActive),
                               @"COMPLETED": @(RARideStatusCompleted)
                               };
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        *success = YES;
        if ([value isKindOfClass:[NSString class]]) {
            return statuses[(NSString*)value] ?: @(RARideStatusUnknown);
        } else {
            return @(RARideStatusUnknown);
        }
    }];
}

+ (NSValueTransformer *)endLocationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideLocationDataModel.class];
}

#pragma mark - Read-only properties

- (CLLocationCoordinate2D)endCoordinate {
    return self.endLocation.coordinate;
}

#pragma mark - Model Update

- (NSArray<NSString *> *)excludeProperties {
    return @[@"endLocation"];
}

- (void)didFinishUpdatingWithModel:(RABaseDataModel *)model {
    RAPrecedingRideDataModel *precedingRide = (RAPrecedingRideDataModel *)model;
    BOOL endLocationUpdated = [self updateProperty:self.endLocation withOtherProperty:precedingRide.endLocation];
    if (endLocationUpdated) {
        self.endLocation = precedingRide.endLocation;
    }
}

@end
