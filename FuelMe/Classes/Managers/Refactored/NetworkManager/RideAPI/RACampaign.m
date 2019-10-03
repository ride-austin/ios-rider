//
//  RACampaign.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACampaign.h"

@implementation RACampaign

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"bannerIcon" : @"bannerIcon",
      @"bannerText" : @"bannerText",
      @"modelID" : @"id",
      @"estimatedFare" : @"estimatedFare"
      };
}

@end
