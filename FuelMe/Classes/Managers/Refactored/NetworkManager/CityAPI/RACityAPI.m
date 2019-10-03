//
//  RACityAPI.m
//  Ride
//
//  Created by Roberto Abreu on 24/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACityAPI.h"

@implementation RACityAPI

+ (void)getCityDetailWithId:(NSNumber *)cityId withCompletion:(void (^)(RACityDetail *cityDetail, NSError *error))handler {
    
    NSDictionary *params = @{@"cityId":cityId,
                             @"configAttributes":@"driverRegistration"
                            };
    
    [[RARequest requestWithPath:kPathGlobalConfig parameters:params mapping:^id(id response) {
        NSDictionary *cityDetailDict = response[@"driverRegistration"];
        RACityDetail *cityDetail = [RAJSONAdapter modelOfClass:[RACityDetail class] fromJSONDictionary:cityDetailDict isNullable:NO];
        if (cityDetail.logoURLwhite) {
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[cityDetail.logoURLwhite]];
        }
        return cityDetail;
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
    
}

@end
