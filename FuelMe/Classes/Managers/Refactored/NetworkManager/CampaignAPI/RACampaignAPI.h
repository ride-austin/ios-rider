//
//  RACampaignAPI.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"
#import "RACampaignDetail.h"
@interface RACampaignAPI : RABaseAPI

+ (void)getCampaignsForProvider:(NSNumber * _Nonnull)providerID withCompletion:(void(^ _Nonnull)(NSArray<RACampaignDetail *> * _Nullable campaigns, NSError *_Nullable error))completion;
+ (void)getCampaignWithID:(NSNumber * _Nonnull)campaignID withCompletion:(void(^ _Nonnull)(RACampaignDetail *_Nullable campaign, NSError *_Nullable error))completion;

@end
