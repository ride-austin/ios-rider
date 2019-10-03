//
//  RAMultipartRequest.m
//  Ride
//
//  Created by Kitos on 5/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAMultipartRequest.h"

@interface RAMultipartRequest ()

- (instancetype)initWithPath:(NSString*)path parameters:(NSDictionary<NSString*,id>*)parameters errorDomain:(ERDomain)errorDomain body:(MultipartBodyBlock)body success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;

@end

@implementation RAMultipartRequest

+ (RAMultipartRequest *)multipartRequestWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters errorDomain:(ERDomain)errorDomain body:(MultipartBodyBlock)body success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [[self alloc] initWithPath:path
                           parameters:parameters
                          errorDomain:errorDomain
                                 body:body
                              success:success
                              failure:failure];
}

- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters errorDomain:(ERDomain)errorDomain body:(MultipartBodyBlock)body success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    
    self = [super initWithPath:path
                        method:POST
                    parameters:parameters
                   errorDomain:errorDomain
             parameterEncoding:FORM
                       mapping:nil
                       success:success
                       failure:failure];

    if (self) {
        self.body = body;
    }
    
    return self;
}

@end
