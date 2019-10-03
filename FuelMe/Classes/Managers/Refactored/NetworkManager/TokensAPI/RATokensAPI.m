//
//  RATokensAPI.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RATokensAPI.h"
#import "RAMacros.h"

NSString *const TokenTypeApple = @"APPLE";

@implementation RATokensAPI

+ (void)postToken:(NSString *)token withCompletion:(void(^)(NSError *error))completion {
    NSString *path = kPathTokens;
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"value"]    = token;
    params[@"type"]     = TokenTypeApple;
    
    [[RARequest requestWithPath:path method:POST parameters:params success:^(NSURLSessionTask *networkTask, id response) {
        DBLog(@"Success registering token: %@", token);
        completion(nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        DBLog(@"Failure registering token: %@", error.localizedRecoverySuggestion);
        completion(error);
    }] execute];
}

@end
