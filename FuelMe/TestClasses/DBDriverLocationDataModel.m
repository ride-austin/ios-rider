//
//  DBDriverLocationDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DBDriverLocationDataModel.h"

@implementation DBDriverLocationDataModel
+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}
+(NSDictionary *)JSONKeyPaths {
    return @{
//             @"id":@"id",
//             @"distanceTravelled":@"distance_travelled",
//             @"distanceTravelledByGoogle":@"distance_travelled_by_google",
             @"latitude":@"latitude",
             @"longitude":@"longitude",
             @"sequence":@"sequence",
             @"trackedOn":@"tracked_on",
//             @"rideId":@"ride_id",
             @"speed":@"speed",
             @"heading":@"heading",
             @"course":@"course",
//             @"originalLatitude":@"original_latitude",
//             @"originalLongitude":@"original_longitude",
             @"valid":@"valid"
             };
}
+ (NSValueTransformer *)trackedOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        if (!self.course || ![self.course isKindOfClass:[NSNumber class]]) {
            self.course = [NSNumber numberWithDouble:0.0];
        }
        if (!self.speed || ![self.speed isKindOfClass:[NSNumber class]]) {
            self.speed = [NSNumber numberWithDouble:0.0];
        }
    }
    return self;
}

-(BOOL)validate:(NSError *__autoreleasing *)error {
    return [super validate:error]
    && self.latitude    != nil
    && self.longitude   != nil;
}
@end
