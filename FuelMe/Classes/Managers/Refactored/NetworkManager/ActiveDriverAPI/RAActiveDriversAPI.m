//
//  RAActiveDriversAPI.m
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAActiveDriversAPI.h"

#import "ConfigurationManager.h"
#import "NSString+CityID.h"

@implementation RAActiveDriversAPI

+ (void)getActiveDrivers:(RAActiveDriversRequest *)activeDriversRequest withCompletion:(RAActiveDriversAPICompletionlock)handler {
    
    if (!activeDriversRequest || ![activeDriversRequest isKindOfClass:[RAActiveDriversRequest class]]) {
        handler(@[], nil, nil);
        return;
    }
    
    CLLocationCoordinate2D location = activeDriversRequest.location;
    RACarCategoryDataModel *carCategory = activeDriversRequest.carCategory;
    
    //FIX: RA-6237 setup params
    NSMutableDictionary * params    = [NSMutableDictionary new];
    params[@"latitude"]             = @(location.latitude);
    params[@"longitude"]            = @(location.longitude);
    params[@"inSurgeArea"]          = carCategory.hasPriority ? @"true" : @"false";
    params[@"carCategory"]          = carCategory.carCategory;
    
    if (activeDriversRequest.isWomanOnlyMode && activeDriversRequest.isFingerPrintedDriverOnlyMode) {
        params[@"driverType"]       = @"WOMEN_ONLY,FINGERPRINTED";
    }
    else if (activeDriversRequest.isWomanOnlyMode) {
        params[@"driverType"]       = @"WOMEN_ONLY";
    }
    else if (activeDriversRequest.isFingerPrintedDriverOnlyMode) {
        params[@"driverType"]       = @"FINGERPRINTED";
    }
    
    RACity *currentCity = [ConfigurationManager shared].global.currentCity;
    if (currentCity.cityID) {
        [params addEntriesFromDictionary:currentCity.requestParameter];
    }
    
    NSString * path = kPathActiveDrivers;
    RARequest *request = [RARequest requestWithPath:path parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[RAActiveDriverDataModel class] fromJSONArray:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, carCategory.mapIconUrl, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, nil, error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUserInteractive;
    [request execute];
}

@end
