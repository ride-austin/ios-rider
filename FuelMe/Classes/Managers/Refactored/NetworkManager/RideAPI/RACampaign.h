//
//  RACampaign.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/15/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RACampaign : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSURL *bannerIcon;
@property (nonatomic, readonly) NSString *bannerText;
@property (nonatomic, readonly) NSNumber *modelID;
@property (nonatomic, readonly) NSString *estimatedFare;

@end
