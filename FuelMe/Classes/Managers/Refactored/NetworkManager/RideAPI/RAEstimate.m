//
//  RAEstimate.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAEstimate.h"

@implementation RAEstimate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"campaignInfo" : @"campaignInfo",
      @"duration" : @"duration",
      @"totalFare" : @"totalFare"
      };
}


+ (NSValueTransformer *)campaignInfoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RACampaign.class];
}

@end
