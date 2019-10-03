//
//  RAConfigAPI.m
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAConfigAPI.h"

@implementation RAConfigAPI

+ (void)getAppConfigurationWithCompletion:(RAConfigAppCompletionBlock)handler {
    NSString *path = kPathRequiredVersion;

    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RAConfigAppDataModel class] fromJSONDictionary:response isNullable:NO];
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

+ (void)getGlobalConfigurationAtCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)(ConfigGlobal *, NSError *))completion {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"lat"] = @(coordinate.latitude);
    params[@"lng"] = @(coordinate.longitude);
    
    [[RARequest requestWithPath:kPathGlobalConfig parameters:params parameterEncoding:JSON errorDomain:GETGlobalConfiguration mapping:^id(id response) {
        ConfigGlobal *global = [RAJSONAdapter modelOfClass:ConfigGlobal.class fromJSONDictionary:response isNullable:NO];
        if (global.urls) {
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:global.urls];
        }
        return global;
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response,nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
    }] execute];
}

@end
