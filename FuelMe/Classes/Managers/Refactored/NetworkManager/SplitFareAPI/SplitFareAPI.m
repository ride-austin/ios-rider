//
//  SplitFareAPI.m
//  Ride
//
//  Created by Roberto Abreu on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SplitFareAPI.h"

#import "RASessionManager.h"

@implementation SplitFareAPI

+ (void)sendSplitFareRequestsToPhoneNumbers:(NSArray<NSString *> *)phoneNumbers inRide:(NSString *)rideID andCompletion:(APIResponseBlock)completion {
    NSMutableString *phoneParams = [[NSMutableString alloc] init];
    for (NSString *phoneNumber in phoneNumbers) {
        [phoneParams appendString:[NSString stringWithFormat:@"phoneNumbers=%@",phoneNumber]];
        if (![phoneNumbers.lastObject isEqual:phoneNumber]) {
            [phoneParams appendString:@"&"];
        }
    }
    
    NSString *path = [[NSString stringWithFormat:kPathRequestSplitFareForRide,rideID,phoneParams] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[RARequest requestWithPath:path method:POST success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response,nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
    }] execute];
}

+ (void)respondToSplitFareRequestForSplitID:(NSString *)splitID withAcceptance:(BOOL)accepted andCompletion:(APIResponseBlock)completion {
    NSString *isAccepted = accepted ? @"true" : @"false";
    NSString *path = [NSString stringWithFormat:kPathSplitFareAccept,splitID];
    
    [[RARequest requestWithPath:path method:POST parameters:@{@"acceptance" : isAccepted} success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response,nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
    }] execute];
}

+ (void)getListOfSplitsByRideID:(NSString *)rideID andCompletion:(SplitFareCompletionBloc)completion {
    NSString *path = [NSString stringWithFormat:kPathSplitFareList,rideID];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[SplitFare class] fromJSONArray:response isNullable:YES];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }] execute];
}

+ (void)removeSplitByID:(NSString *)splitID andCompletion:(APIErrorResponseBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathSplitFareSpecific,splitID];
    
    [[RARequest requestWithPath:path method:DELETE success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(error);
        }
    }] execute];
}

+ (void)getPendingSplitRequestsForCurrentRiderWithCompletion:(SplitFareCompletionBloc)completion {
    NSString *riderID = [[[[RASessionManager sharedManager] currentUser] riderID] stringValue];
    if (!riderID) {
        NSError *error = [NSError errorWithDomain:@"GESplitList" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"User not valid"}];
        [ErrorReporter recordError:error withDomainName:GETSplitList];
        completion(nil,error);
        return;
    }
    
    [self getPendingSplitRequestsForRiderID:riderID withCompletion:completion];
}

+ (void)getPendingSplitRequestsForRiderID:(NSString *)riderID withCompletion:(SplitFareCompletionBloc)completion {
    NSString *path = [NSString stringWithFormat:kPathSplitFareRequested,riderID];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[SplitFare class] fromJSONArray:response isNullable:YES];
        
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
    }] execute];
}


@end
