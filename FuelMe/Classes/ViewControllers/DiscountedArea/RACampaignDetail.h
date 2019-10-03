//
//  RACampaignDetail.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "RACampaignArea.h"

@interface RACampaignDetail : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSURL *headerIcon;
@property (nonatomic, readonly) NSString *headerTitle;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *footer;
@property (nonatomic, readonly) NSArray<RACampaignArea *> *areas;

@end
