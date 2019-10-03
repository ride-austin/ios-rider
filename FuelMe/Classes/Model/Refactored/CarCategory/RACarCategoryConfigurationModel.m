//
//  RACarCategoryConfigurationModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACarCategoryConfigurationModel.h"

@implementation RACarCategoryConfigurationModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"allowedPolygons"        : @"allowedPolygons",
              @"available"              : @"available",
              @"zeroFareLabel"          : @"zeroFareLabel",
              @"showAlert"              : @"showAlert",
              @"disableTipping"         : @"disableTipping",
              @"disableCancellationFee" : @"disableCancellationFee"
            };
}

+ (NSValueTransformer *)availableJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigUTAvailability class]];
}

+ (NSValueTransformer *)allowedPolygonsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[CategoryBoundaryPolygon class]];
}

@end
