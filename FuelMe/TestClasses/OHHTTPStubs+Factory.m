//
//  OHHTTPStubs+Factory.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "OHHTTPStubs+Factory.h"
#import "NSString+urlParameters.h"
#import <AFNetworking/AFURLResponseSerialization.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>
@implementation OHHTTPStubs (Factory)
+ (void)addStubWithRequestPath:(NSString *)path
                        method:(NSString *)httpMethod
                    statusCode:(int)statusCode
                   andFileName:(NSString *)fileName
           requiringParameters:(NSArray<NSString *> *)mandatoryParameters {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        if ([normalizeRequestPath isEqualToString:path] &&
            [request.HTTPMethod isEqualToString:httpMethod]) {
            
            NSString *urlParameters = [[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding];
            NSDictionary *params = urlParameters.dictionary;
            for (NSString *mandatoryParameter in mandatoryParameters) {
                id value = params[mandatoryParameter];
                if (value == nil || [value isEqualToString:@"(null)"]) {
                    return NO;
                }
            }
            return YES;
        } else {
            return NO;
        }
    } withStubResponse:[self handlerResponseWithStatusCode:statusCode andFileName:fileName]];
}
+ (OHHTTPStubsResponseBlock)handlerResponseWithStatusCode:(int)statusCode andFileName:(NSString*)fileName {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSAssert(path, @"Not file found with fileName : %@",fileName);
        return [OHHTTPStubsResponse responseWithFileAtPath:path statusCode:statusCode headers:@{@"Content-type":@"application/json"}];
    };
}

+ (void)addStubWithPOSTRequestPath:(NSString *)path errorCode:(NSInteger)errorCode andServerMessage:(NSString *)message {
    
    NSString *httpMethod = @"POST";
    
    NSError *error = [NSError serverErrorWithPath:path errorCode:errorCode andMessage:message];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        return [normalizeRequestPath isEqualToString:path] && [request.HTTPMethod isEqualToString:httpMethod];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

@end

@implementation NSError (ServerError)

+ (instancetype)serverErrorWithPath:(NSString *)path errorCode:(NSInteger)errorCode andMessage:(NSString *)message {
    
    NSURL *url = [NSURL URLWithString:path]; //incomplete
    NSDictionary *headers = nil;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:errorCode HTTPVersion:nil headerFields:headers];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *userInfo =
    @{
      NSLocalizedDescriptionKey:@"SOME UNUSED ERROR DESCRIPTION",
      AFNetworkingOperationFailingURLResponseDataErrorKey:data,
      AFNetworkingOperationFailingURLResponseErrorKey:response
      };
    return [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
}
@end
