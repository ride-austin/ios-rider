//
//  RARequest.h
//  Ride
//
//  Created by Kitos on 4/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ERDomains.h"

@class AFHTTPRequestOperation;

typedef NS_ENUM(NSUInteger,RAMethod){
    GET = 0,
    POST,
    PUT,
    DELETE
};

typedef NS_ENUM(NSUInteger,RAClientParameterEncoding){
    FORM = 0,
    JSON
};

typedef id   (^MappingCompletionBlock)(id response);
typedef void (^NetworkSuccessBlock)(NSURLSessionTask *networkTask, id response);
typedef void (^NetworkFailureBlock)(NSURLSessionTask *networkTask, NSError *error);
typedef void (^NetworkCompletionBlock)(NSError *error);

@interface RARequest : NSObject

@property (nonatomic) RAMethod method;                                  // Default: GET
@property (nonatomic, strong) NSString *mappingQueueType;               // Default: QueueTypeBackground;See RANetworkManagerQueues.h
@property (nonatomic, strong) NSString *clientName;                     // Default: nil
@property (nonatomic, strong) NSString *path;                           // Default: nil
@property (nonatomic, strong) NSDictionary<NSString*, id> *parameters;  // Default: nil
@property (nonatomic, copy) MappingCompletionBlock mapping;             // Default: nil
@property (nonatomic, copy) NetworkSuccessBlock success;                // Default: nil
@property (nonatomic, copy) NetworkFailureBlock failure;                // Default: nil
@property (nonatomic) ERDomain errorDomain;                             // Default: UnspecifiedDomain
@property (nonatomic) RAClientParameterEncoding parameterEncoding;      // Default: FORM
@property(nonatomic, strong) NSString *username;                        // Default: nil
@property(nonatomic, strong) NSString *password;                        // Default: nil
@property(nonatomic) BOOL useAuthorizationHeader;                       // Default: NO

+ (RARequest*)requestWithPath:(NSString*)path success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString *,id> *)parameters mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path parameters:(NSDictionary<NSString *,id> *)parameters mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path parameters:(NSDictionary<NSString *,id> *)parameters parameterEncoding:(RAClientParameterEncoding)parameterencoding errorDomain:(ERDomain)errorDomain mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method errorDomain:(ERDomain)errorDomain success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain parameterEncoding:(RAClientParameterEncoding)parameterencoding success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;
+ (RARequest*)requestWithPath:(NSString*)path method:(RAMethod)method parameters:(NSDictionary<NSString*, id>*)parameters errorDomain:(ERDomain)errorDomain parameterEncoding:(RAClientParameterEncoding)parameterencoding mapping:(MappingCompletionBlock)mapping success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;

- (instancetype)initWithPath:(NSString*)path
                     method:(RAMethod)method
                 parameters:(NSDictionary<NSString*, id>*)parameters
                errorDomain:(ERDomain)errorDomain
          parameterEncoding:(RAClientParameterEncoding)parameterencoding
                    mapping:(MappingCompletionBlock)mapping
                    success:(NetworkSuccessBlock)success
                    failure:(NetworkFailureBlock)failure;

- (void)execute;

@end
