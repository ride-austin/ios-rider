//
//  NSError+ErrorFactory.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSError+ErrorFactory.h"

#import <SystemConfiguration/SystemConfiguration.h>

#import "RAEnvironmentManager.h"

#import <AFNetworking/AFNetworking.h>

@implementation NSError (ErrorFactory)

- (NSError *)filteredError {
    NSMutableDictionary *userInfo = self.userInfo ? [NSMutableDictionary dictionaryWithDictionary:self.userInfo] : [NSMutableDictionary dictionary];

    switch (self.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorNotConnectedToInternet:
            if (!userInfo[NSLocalizedRecoverySuggestionErrorKey]) {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = userInfo[NSLocalizedDescriptionKey];
            }
            return [NSError errorWithDomain:self.domain code:self.code userInfo:userInfo];
            
        default: {
            NSHTTPURLResponse *httpResponse = userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            return [self errorWithStatusCode:httpResponse.statusCode];
        }
    }
}

- (NSError *)errorWithStatusCode:(NSInteger)statusCode {
    NSMutableDictionary *userInfo = self.userInfo ? [NSMutableDictionary dictionaryWithDictionary:self.userInfo] : [NSMutableDictionary dictionary];
    
    NSData *serverErrorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSString *serverErrorString = [[NSString alloc] initWithData:serverErrorData encoding:NSUTF8StringEncoding];
    
    if ([serverErrorString isKindOfClass:NSString.class]) {
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = serverErrorString;
    }
    
    NSString* recoveryOptions = userInfo[NSLocalizedRecoverySuggestionErrorKey];
    if ([recoveryOptions.lowercaseString hasPrefix:@"<html"] ||
        [recoveryOptions.lowercaseString hasSuffix:@"</html>"]) {
        recoveryOptions = nil;
    }
    NSString *version = [NSString stringWithFormat:@" (%@)", [RAEnvironmentManager sharedManager].version];
    
    NSMutableString *displayMessage = [NSMutableString new];
    [displayMessage appendString:[self messageBasedOnStatusCode:statusCode andRecoveryOptions:recoveryOptions]];
    [displayMessage appendString:version];
    userInfo[NSLocalizedRecoverySuggestionErrorKey] = displayMessage;
    return [NSError errorWithDomain:self.domain code:statusCode userInfo:userInfo];
}

- (NSString *)messageBasedOnStatusCode:(NSInteger)statusCode andRecoveryOptions:(NSString *)recoveryOptions {
    switch (statusCode) {
        case 0:     return recoveryOptions ?: self.localizedDescription;
        case 400:   return recoveryOptions ?: @"There was an issue with your request. Please contact support.";
        case 401:
            if ([recoveryOptions.lowercaseString containsString:@"user is disable"]) {
                return @"There was an issue with your request. Please contact support.";
            } else {
                return recoveryOptions ?: @"You are not authorized.";
            }
            
        case 403:   return recoveryOptions ?: @"You are not allowed to view this resource.";
        case 404:   return recoveryOptions ?: @"Resource does not exist.";
        case 409:   return recoveryOptions ?: @"Resource already exists";
        case 500:
        default:
            return recoveryOptions ?: [NSString stringWithFormat:@"We are currently experiencing technical issues! (Code:%li)", (long)statusCode];
    }
}

@end

#import "ConfigurationManager.h"
@implementation NSError (ConstantErrors)

+ (NSError *)facebookPhoneNotProvidedError {
    return [NSError errorWithDomain:@"com.rideaustin.facebookLogin.NoPhoneError" code:202 userInfo:nil];
}

+ (NSError *)facebookEmailNotProvidedError {
    return [NSError errorWithDomain:@"com.rideaustin.error.facebook.email.notFound" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"We are unable to access your email associated with Facebook.\nPlease check your permissions for %@ and/or create a %@ account using your email.",[ConfigurationManager appName], [ConfigurationManager appName]]}];
}

+ (NSError *)accountNotEnabledError {
    return [NSError errorWithDomain:@"com.rideaustin.logn.error.notenabled" code:-2 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Your account is disabled. Please contact support@rideaustin.com"}];
}

+ (NSError *)initiatedThirdPartyWhileOnTripError {
    return [NSError errorWithDomain:@"com.rideaustin.initiated.third.party.error" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Please finish the current ride before starting a new one"}];
}

@end
