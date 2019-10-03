//
//  TripHistoryAPI.m
//  Ride
//
//  Created by Robert on 8/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TripHistoryAPI.h"

static NSString const* kTripHistories = @"kTripHistories";
static NSString const* kTotalPages = @"kTotalPages";

@implementation TripHistoryAPI

+ (void)getTripHistoryWithRiderId:(NSString *)riderId limit:(NSNumber *)pageSize offset:(NSNumber *)page completion:(TripHistoryCompletion)handler {
    
    NSString *path = [NSString stringWithFormat:kPathRidersPayments,riderId];
    NSDictionary *params = @{ @"page":page,
                             @"pageSize":pageSize,
                             @"desc":@YES
                           };
    
    [[RARequest requestWithPath:path parameters:params mapping:^id(id response) {
        NSArray *contentResponse = response[@"content"];
        NSArray *tripHistories = [RAJSONAdapter modelsOfClass:TripHistoryDataModel.class fromJSONArray:contentResponse isNullable:NO];
        [tripHistories enumerateObjectsUsingBlock:[self reportInvalidResponse:contentResponse]];
        
        NSUInteger totalPages = [response[@"totalPages"] integerValue];
        return @{kTripHistories : tripHistories,
                 kTotalPages    : @(totalPages)};
    } success:^(NSURLSessionTask *networkTask, id response) {
        NSDictionary *responseDict = (NSDictionary*)response;
        if (handler) {
            handler(responseDict[kTripHistories],[responseDict[kTotalPages] integerValue],nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, 0, error);
        }
    }] execute];
}

+ (void(^)(TripHistoryDataModel *obj, NSUInteger idx, BOOL * stop))reportInvalidResponse:(NSArray *)contentResponse {
    return ^(TripHistoryDataModel *obj, NSUInteger idx, BOOL * stop) {
        if (obj.status == TripStatusUnsupported) {
            [ErrorReporter recordErrorDomainName:GETRidersPayments withUserInfo:contentResponse[idx]];
        }
    };
}

@end
