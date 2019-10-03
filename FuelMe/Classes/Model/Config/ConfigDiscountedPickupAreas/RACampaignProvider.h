//
//  RACampaignProviders.h
//  RideAustin
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RACampaignProvider : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSNumber *modelID;
@property (nonatomic, readonly) NSString *menuTitle;
@property (nonatomic, readonly) NSURL *menuIcon;

@end
