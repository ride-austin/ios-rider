//
//  RAEstimate.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "RACampaign.h"
@interface RAEstimate : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) RACampaign *campaignInfo;
@property (nonatomic, readonly) NSNumber *duration;
@property (nonatomic, readonly) NSString *totalFare;

@end
