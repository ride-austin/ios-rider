//
//  ConfigRides.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigRides.h"

@implementation ConfigRides
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"distanceToAskPickupPrompt":@"distantPickUpNotificationThreshold",
             @"distanceToRestrictPickup":@"distanceToRestrictPickup",
             @"rideSummaryDescription":@"rideSummaryDescription",
             @"rideSummaryDescriptionFreeCreditCharged":@"rideSummaryDescriptionFreeCreditCharged"
            };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _distanceToAskPickupPrompt = @(200);
        _distanceToRestrictPickup  = @(20000);
        _rideSummaryDescription = @"Eligible credits will be applied on your emailed receipt.";
        _rideSummaryDescriptionFreeCreditCharged = @"Eligible credits have been applied";
    }
    return self;
}

@end
