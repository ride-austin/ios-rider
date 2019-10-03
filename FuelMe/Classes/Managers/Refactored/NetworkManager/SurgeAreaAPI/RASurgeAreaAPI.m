//
//  RASurgeAreaAPI.m
//  Ride
//
//  Created by Kitos on 17/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RASurgeAreaAPI.h"

#import "NSString+CityID.h"

@implementation RASurgeAreaAPI

static NSString *const kSurgeAreasRLatitudeField    = @"latitude";
static NSString *const kSurgeAreasLongitudeField    = @"longitude";
static NSString *const kSurgeAreasContentKey        = @"content";

+ (void)getSurgeAreasAtCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(RASurgeAreasCompletionBlock)handler {
    NSString *path = kPathSurgeAreas;
    path = [path pathWithCityAppendType:AppendAsFirstParameter];
    
    NSNumber *latitude   = @(coordinate.latitude);
    NSNumber *longitude  = @(coordinate.longitude);
    NSDictionary *params = @{
                             kSurgeAreasRLatitudeField  : latitude,
                             kSurgeAreasLongitudeField  : longitude
                             };
    
    [[RARequest requestWithPath:path parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[RASurgeAreaDataModel class] fromJSONArray:response[kSurgeAreasContentKey] isNullable:NO];
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
