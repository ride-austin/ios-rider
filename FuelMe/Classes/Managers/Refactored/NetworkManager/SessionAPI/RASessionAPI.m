//
//  RASessionAPI.m
//  RideAustin
//
//  Created by Kitos on 3/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RASessionAPI.h"
#import "NSError+ErrorFactory.h"

@implementation RASessionAPI

@end

#pragma mark - Sign In

@implementation RASessionAPI (SignIn)

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password encrypt:(BOOL)encrypt andCompletion:(RASessionCompletionBlock)handler {
    NSString *path = kPathLogin;
    
    RARequest *request = [RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RASessionDataModel class] fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }];
    
    NSString *passwordEncripted = encrypt ? [RAUserDataModel securePasswordWithEmail:username andPassword:password] : password;
    request.username = username;
    request.password = passwordEncripted;
    request.useAuthorizationHeader = YES;
    request.method = POST;
    request.errorDomain = POSTLogin;
    [request execute];
}

+ (void)loginWithFacebook:(NSString *)facebookToken andCompletion:(RAPartialSessionCompletionBlock)handler {
    NSString *path = kPathFacebookLogin;
    NSDictionary *params = nil;
    if (facebookToken) {
        params = @{@"token":facebookToken};
    }
    
    [[RARequest requestWithPath:path method:POST parameters:params errorDomain:POSTFacebookLogin success:^(NSURLSessionTask *networkTask, id response) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse*)networkTask.response;
        if (httpURLResponse.statusCode == NSError.facebookPhoneNotProvidedError.code) {
            if (handler) {
                handler(NSError.facebookPhoneNotProvidedError);
            }
        } else {
            if (handler) {
                handler(nil);
            }
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(error);
        }
    }] execute];
}

@end

#pragma mark - Sign Out

@implementation RASessionAPI (SignOut)

+ (void)logoutWithCompletion:(APIResponseBlock)handler {
    NSString *path = kPathLogout;
    [[RARequest requestWithPath:path method:POST success:^(NSURLSessionTask *networkTask, id response) {
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

#pragma mark - Recover Password

@implementation RASessionAPI (ForgotPassword)

+ (void)recoverPasswordFromEmail:(NSString *)email withCompletion:(APIResponseBlock)handler {
    NSString *path = kPathRecoverPassword;
    NSDictionary *params = @{@"email" : email};
    
    [[RARequest requestWithPath:path method:POST parameters:params success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(nil, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

@end

@implementation RASessionAPI (ChangePassword)

+ (void)updatePassword:(NSString *)password withCompletion:(APIResponseBlock)handler {
    NSString *path = kPathChangePassword;
    NSDictionary *params = @{ @"password": password };
    
    [[RARequest requestWithPath:path method:POST parameters:params parameterEncoding:FORM success:^(NSURLSessionTask *networkTask, id response) {
        handler(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        handler(nil, error);
    }] execute];
}

@end
