//
//  SupportTopicAPI.m
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SupportTopicAPI.h"
#import "RAMacros.h"

@implementation SupportTopicAPI

+ (void)getSupportTopicListWithCompletion:(SupportTopicBlock)handler {
    
    [[RARequest requestWithPath:kPathSupportTopic mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[SupportTopic class] fromJSONArray:response isNullable:NO];
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

+ (void)getTopicsWithParentId:(NSNumber *)parentTopicId withCompletion:(SupportTopicBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicChildren,parentTopicId];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[SupportTopic class] fromJSONArray:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil,error);
        }
    }] execute];
}

+ (void)getFormForTopic:(SupportTopic *)topic withCompletion:(void(^)(LIOptionDataModel *, NSError *))completion {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicForm, topic.modelID];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[LIOptionDataModel class] fromJSONDictionary:response isNullable:NO];
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

+ (void)postSupportMessage:(NSString *)comment supportTopic:(SupportTopic *)supportTopic rideId:(NSNumber *)rideId withCompletion:(SupportTopicPostMessageBlock)handler {
    
    NSDictionary *params = @{@"rideId"   : rideId,
                             @"comments" : comment,
                             @"topicId"  : supportTopic.modelID };
    
    [[RARequest requestWithPath:kPathSupportTopicMessage
                         method:POST
                     parameters:params
              parameterEncoding:JSON
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }]
     execute];
}

+(void)postSupportMessage:(NSString *)message rideID:(NSString *)rideID cityID:(NSNumber *)cityID withCompletion:(void (^)(NSError * _Nullable))completion {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"message"] = message;
    parameters[@"rideId"]  = rideID;
    parameters[@"cityId"]  = cityID;
    
    [[RARequest requestWithPath:kPathSupport method:POST parameters:parameters parameterEncoding:FORM success:^(NSURLSessionTask *networkTask, id response) {
        completion(nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(error);
    }] execute];
}

#pragma mark - Lost Items
#pragma mark Rider

+ (void)postLostAndFoundLostParameters:(NSDictionary *)params withCompletion:(void(^)(NSString *message, NSError* error))completion {
    NSString *path = kPathLostAndFoundLost;
    [[RARequest requestWithPath:path
                         method:POST parameters:params
                        success:^(NSURLSessionTask *networkTask, id response) {
                            DBLog(@"%@: %@",path, response);
                            if (completion) {
                                completion(response[@"message"], nil);
                            }
                        } failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (completion) {
                                completion(nil, error);
                            }
                        }] execute];
    
}

+ (void)postLostAndFoundContactParameters:(NSDictionary *)params withCompletion:(void(^)(NSString* message, NSError* error))completion {
    NSString *path = kPathLostAndFoundContact;
    [[RARequest requestWithPath:path
                         method:POST parameters:params
                        success:^(NSURLSessionTask *networkTask, id response) {
                            DBLog(@"%@: %@",path, response);
                            if (completion) {
                                completion(response[@"message"], nil);
                            }
                        } failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (completion) {
                                completion(nil,error);
                            }
                        }] execute];
}

#pragma mark Driver

+(void)postLostAndFoundFoundParameters:(NSDictionary *)params
                             andImages:(NSDictionary<NSString *,NSData *> *)images
                        withCompletion:(LostAndFoundBlock)completion {
    NSString *path = kPathLostAndFoundFound;
    
    NSError *error;
    NSData *itemData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error) {
        completion(nil, error);
        return;
    }
    [[RAMultipartRequest multipartRequestWithPath:path parameters:nil errorDomain:UnspecifiedDomain body:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:itemData
                                    name:@"item"
                                fileName:@"item.json"
                                mimeType:@"application/json"];
        for (NSString *imageVariable in images.allKeys) {
            NSString *name = [NSString stringWithFormat:@"%@.png",imageVariable];
            [formData appendPartWithFileData:images[imageVariable]
                                        name:imageVariable
                                    fileName:name
                                    mimeType:@"image/png"];
        }
    } success:^(NSURLSessionTask *networkTask, id response) {
        DBLog(@"%@: %@",path, response);
        completion(response[@"message"], nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

+ (void)postLostAndFoundFoundParameters:(NSDictionary *)params withCompletion:(void(^)(NSString* message, NSError* error))completion {
    NSString *path = kPathLostAndFoundFound;
    [[RARequest requestWithPath:path
                         method:POST parameters:params
                        success:^(NSURLSessionTask *networkTask, id response) {
                            DBLog(@"%@: %@",path, response);
                            if (completion) {
                                completion(response[@"message"],nil);
                            }
                        } failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (completion) {
                                completion(nil,error);
                            }
                        }] execute];
}
@end
