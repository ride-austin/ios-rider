//
//  SupportTopic.m
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SupportTopic.h"

@implementation SupportTopic

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[SupportTopic JSONKeyPaths]];
}

+ (NSDictionary*)JSONKeyPaths {
    return @{ @"topicDescription" : @"description",
              @"hasChildren"      : @"hasChildren",
              @"hasForms"         : @"hasForms"
              };
}

@end
