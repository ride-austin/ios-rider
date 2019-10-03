//
//  OHHTTPStubs+Factory.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface OHHTTPStubs (Factory)
+ (void)addStubWithRequestPath:(NSString * _Nonnull)path
                        method:(NSString * _Nonnull)httpMethod
                    statusCode:(int)statusCode
                   andFileName:(NSString * _Nonnull)fileName
           requiringParameters:(NSArray<NSString *> *_Nullable)mandatoryParameters;

+ (void)addStubWithPOSTRequestPath:(NSString * _Nonnull)path errorCode:(NSInteger)errorCode andServerMessage:(NSString * _Nonnull)message;
@end

@interface NSError (ServerError)

+ (instancetype _Nonnull)serverErrorWithPath:(NSString * _Nonnull)path errorCode:(NSInteger)errorCode andMessage:(NSString * _Nonnull)message;

@end
