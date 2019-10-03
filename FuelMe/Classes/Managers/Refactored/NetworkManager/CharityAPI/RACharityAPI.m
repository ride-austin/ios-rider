//
//  RACharityAPI.m
//  RideAustin
//
//  Created by Kitos on 8/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RACharityAPI.h"

#import "NSString+CityID.h"

@implementation RACharityAPI

+ (void)getAllCharitiesWithCompletion:(RACharitiesAPICompletionBlock)handler {
    NSString *path = kPathCharities;
    path = [path pathWithCityAppendType:AppendAsFirstParameter];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[RACharityDataModel class] fromJSONArray:response isNullable:NO];
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
