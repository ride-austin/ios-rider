//
//  RACampaignDetail.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACampaignDetail.h"

@implementation RACampaignDetail

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"headerIcon" : @"headerIcon",
      @"headerTitle" : @"headerTitle",
      @"body" : @"body",
      @"footer" : @"footer",
      @"areas" : @"areas"
      };
}

+ (NSValueTransformer *)areasJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RACampaignArea.class];
}

@end
