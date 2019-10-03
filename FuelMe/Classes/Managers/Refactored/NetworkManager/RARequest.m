//
//  RARequest.m
//  Ride
//
//  Created by Kitos on 4/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARequest.h"

#import "RANetworkManager.h"
#import "RANetworkManagerQueues.h"

@interface RARequest ()

@property (nonatomic, readonly) NSString* methodString;
@property (nonatomic, readonly) NSString* parameterEncodingString;

@end

@implementation RARequest

#pragma mark - Initializers

+ (RARequest *)requestWithPath:(NSString *)path success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:GET
                              success:success
                              failure:failure];
}

+ (RARequest*)requestWithPath:(NSString*)path mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    return [RARequest requestWithPath:path
                           parameters:nil
                              mapping:mapping
                              success:success
                              failure:failure];
}

+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString *,id> *)parameters mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    return [RARequest requestWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:UnspecifiedDomain
                    parameterEncoding:FORM
                              mapping:mapping
                              success:success
                              failure:failure];
}

+ (RARequest*)requestWithPath:(NSString*)path parameters:(NSDictionary<NSString *,id> *)parameters mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    return [RARequest requestWithPath:path
                           parameters:parameters
                    parameterEncoding:FORM
                          errorDomain:UnspecifiedDomain
                              mapping:mapping
                              success:success
                              failure:failure];
}

+ (RARequest*)requestWithPath:(NSString*)path parameters:(NSDictionary<NSString *,id> *)parameters parameterEncoding:(RAClientParameterEncoding)parameterencoding errorDomain:(ERDomain)errorDomain mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    return [RARequest requestWithPath:path
                               method:GET
                           parameters:parameters
                          errorDomain:errorDomain
                    parameterEncoding:parameterencoding
                              mapping:mapping
                              success:success
                              failure:failure];
}

+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:nil
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameters:(NSDictionary<NSString *,id> *)parameters success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:UnspecifiedDomain
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method errorDomain:(ERDomain)errorDomain success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:nil
                          errorDomain:errorDomain
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameters:(NSDictionary<NSString *,id> *)parameters errorDomain:(ERDomain)errorDomain success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:errorDomain
                    parameterEncoding:FORM
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:nil
                    parameterEncoding:parameterencoding
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameters:(NSDictionary<NSString *,id> *)parameters parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:UnspecifiedDomain
                    parameterEncoding:parameterencoding
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [RARequest requestWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:errorDomain
                    parameterEncoding:parameterencoding
                              mapping:nil
                              success:success
                              failure:failure];
}

+ (RARequest *)requestWithPath:(NSString *)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain parameterEncoding:(RAClientParameterEncoding)parameterencoding mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure{
    return [[self alloc] initWithPath:path
                               method:method
                           parameters:parameters
                          errorDomain:errorDomain
                    parameterEncoding:parameterencoding
                              mapping:mapping
                              success:success
                              failure:failure];
}

- (instancetype)initWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain parameterEncoding:(RAClientParameterEncoding)parameterencoding mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    if (self = [super init]) {
        self.path = path;
        self.method = method;
        self.parameters = parameters;
        self.errorDomain = errorDomain;
        self.parameterEncoding = parameterencoding;
        self.mapping = mapping;
        self.success = success;
        self.failure = failure;
        self.mappingQueueType = QueueTypeBackground;
        self.username = nil;
        self.password = nil;
        self.useAuthorizationHeader = NO;
    }
    return self;
}

#pragma mark - Methods

- (void)execute{
    [[RANetworkManager sharedManager] executeRequest:self];
}

#pragma mark - Helpers

- (NSString *)methodString{
    switch (self.method) {
        case GET:
            return @"GET";
            break;
        case POST:
            return @"POST";
            break;
        case PUT:
            return @"PUT";
            break;
        case DELETE:
            return @"DELETE";
            break;
            
        default:
            return @"UNKNOWN";
            break;
    }
}

- (NSString *)parameterEncodingString{
    switch (self.parameterEncoding) {
        case FORM:
            return @"FORM";
            break;
        case JSON:
            return @"JSON";
            break;
            
        default:
            return @"UNKNOWN";
            break;
    }
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: [%@ %@](%@)%@>",NSStringFromClass(self.class) ,self.methodString,self.path,self.parameterEncodingString,self.parameters?[NSString stringWithFormat:@"\n%@",self.parameters]:@""];
}

@end
