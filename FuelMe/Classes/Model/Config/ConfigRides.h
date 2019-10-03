//
//  ConfigRides.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigRides : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSNumber *distanceToAskPickupPrompt;
@property (nonatomic, readonly) NSNumber *distanceToRestrictPickup;
@property (nonatomic, readonly) NSString *rideSummaryDescription;
@property (nonatomic, readonly) NSString *rideSummaryDescriptionFreeCreditCharged;

@end
