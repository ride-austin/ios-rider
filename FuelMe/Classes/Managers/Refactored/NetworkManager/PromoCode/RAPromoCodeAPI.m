//
//  RAPromoCodeAPI.m
//  Ride
//
//  Created by Roberto Abreu on 9/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPromoCodeAPI.h"

#import "RAEnvironmentManager.h"
#import "RASessionManager.h"

@implementation RAPromoCodeAPI

+ (void)applyPromoCode:(NSString *)code completion:(PromoCodeCompletionBlock)completion {
    NSString *riderID = [[[[RASessionManager sharedManager] currentUser] riderID] stringValue];
    
    if (!riderID) {
        NSError *error = [NSError errorWithDomain:@"com.rideaustin.rider.promocode.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat: @"Use promo code error: Rider ID is missing V%@",[RAEnvironmentManager sharedManager].version]}];
        
        if (completion) {
            completion(nil, error);
        }
        return;
    }
        
    NSString *path = [NSString stringWithFormat:kPathRidersPromoCode, riderID];
    NSDictionary *params = @{ @"codeLiteral" : code };
    
    [[RARequest requestWithPath:path method:POST parameters:params errorDomain:POSTPromo parameterEncoding:JSON mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RAPromoCode class] fromJSONDictionary:response isNullable:NO];
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

+ (void)getMyPromoCodeWithCompletion:(PromoCodeCompletionBlock)completion {
    NSString *riderID = [[[[RASessionManager sharedManager] currentUser] riderID] stringValue];
    if (!riderID) {
        NSError *error = [NSError errorWithDomain:@"com.rideaustin.rider.promocode.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat: @"Get promo code error: Rider ID is missing V%@",[RAEnvironmentManager sharedManager].version]}];
        [ErrorReporter recordError:error withDomainName:GETPromoCode];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    NSString *path = [NSString stringWithFormat:kPathRidersPromoCode, riderID];
    RARequest *request = [RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RAPromoCode class] fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
    
    request.errorDomain = GETPromoCode;
    [request execute];
}

@end
