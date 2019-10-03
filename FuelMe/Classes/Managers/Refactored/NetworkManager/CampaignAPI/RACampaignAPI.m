//
//  RACampaignAPI.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACampaignAPI.h"

@implementation RACampaignAPI

+ (void)getCampaignsForProvider:(NSNumber *)providerID withCompletion:(void (^)(NSArray<RACampaignDetail *> * _Nullable, NSError * _Nullable))completion {
    NSString *path = [NSString stringWithFormat:kPathCampaignsProviders, providerID];
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:RACampaignDetail.class fromJSONArray:response isNullable:YES]; //make this NO when server with cap metro is released
    } success:^(NSURLSessionTask *networkTask, NSArray<RACampaignDetail *> *response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

+ (void)getCampaignWithID:(NSNumber *)campaignID withCompletion:(void (^)(RACampaignDetail * _Nullable, NSError * _Nullable))completion {
    NSString *path = [NSString stringWithFormat:kPathCampaignsSpecific, campaignID];
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RACampaignDetail.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, RACampaignDetail *response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

@end
