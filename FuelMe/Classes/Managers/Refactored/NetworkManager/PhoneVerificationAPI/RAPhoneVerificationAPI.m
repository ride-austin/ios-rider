//
//  RAPhoneVerificationAPI.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPhoneVerificationAPI.h"

@implementation RAPhoneVerificationAPI

#pragma mark - Phone Verification

+ (void)postVerifyPhoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(NSString *token, NSError *error))completion {
    NSString *path = kPathPhoneVerificationRequestCode;
    NSDictionary *parameters = @{@"phoneNumber":phoneNumber};
    [[RARequest requestWithPath:path method:POST parameters:parameters parameterEncoding:FORM success:^(NSURLSessionTask *networkTask, id response) {
        NSString *token = response[@"token"];
        if ([token isKindOfClass:[NSString class]]) {
            completion(token,nil);
        } else {
            NSError *error = [ErrorReporter recordErrorDomainName:POSTPhoneVerificationRequest withInvalidResponse:response];
            completion(nil,error);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

+ (void)postVerifyCode:(NSString *)code token:(NSString *)token withCompletion:(void(^)(BOOL success, NSError *error))completion {
    NSString *path = kPathPhoneVerificationVerify;
    NSDictionary *parameters = @{@"authToken":token,
                                 @"code":code};
    [[RARequest requestWithPath:path method:POST parameters:parameters parameterEncoding:FORM success:^(NSURLSessionTask *networkTask, id response) {
        completion(YES, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(NO, error);
    }] execute];
}

@end
