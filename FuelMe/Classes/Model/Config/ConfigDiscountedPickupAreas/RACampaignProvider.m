//
//  RACampaignProviders.m
//  RideAustin
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACampaignProvider.h"

@implementation RACampaignProvider

+ (void)load {
    //Added in 5.0
    [NSKeyedUnarchiver setClass:[RACampaignProvider class] forClassName:@"RACampaignProviders"];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"modelID" : @"id",
      @"menuTitle" : @"menuTitle",
      @"menuIcon" : @"menuIcon"
      };
}

@end
