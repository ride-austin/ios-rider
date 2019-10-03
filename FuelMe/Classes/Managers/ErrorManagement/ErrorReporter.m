//
//  ErrorReporter.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ErrorReporter.h"
#import "RAEnvironmentManager.h"
#import "RAMacros.h"
#import <Crashlytics/Crashlytics.h>

@implementation ErrorReporter

+ (NSError *)recordErrorDomainName:(ERDomain)erDomainName withInvalidResponse:(id)response {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    if (!response) {
        mDict[@"response"] = @"nil";
    } else if ([response isKindOfClass:[NSNull class]]) {
        mDict[@"response"] = @"NSNull";
    } else {
        mDict[@"response"] = response;
    }
    return [self recordErrorDomainName:erDomainName withUserInfo:mDict];
}

+ (NSError *)recordErrorDomainName:(ERDomain)erDomainName withUserInfo:(NSDictionary *)userInfo {
    NSString *domainName   = [ErrorReporter stringForDomainName:erDomainName];
    NSString *version      = [NSString stringWithFormat:@"V%@",[RAEnvironmentManager sharedManager].version];
    NSString *errorMessage = [NSString stringWithFormat:@"%@ %@", domainName, version];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [mDict addEntriesFromDictionary:@{NSLocalizedRecoverySuggestionErrorKey : errorMessage}];
    
    NSError *error = [NSError errorWithDomain:domainName code:erDomainName userInfo:mDict];
    [self recordError:error withDomainName:erDomainName];
    return error;
}

+ (void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName {
    [self recordError:error withDomainName:erDomainName andCustomName:nil];
}

+ (void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName andCustomName:(NSString *)customDomainName {
    BOOL hasValidError = [error isKindOfClass:[NSError class]];
    if (hasValidError) {
        NSString *domainName = [self stringForDomainName:erDomainName];
        if ([customDomainName isKindOfClass:[NSString class]]) {
            domainName = customDomainName;
        }
        NSError *newError = [NSError errorWithDomain:domainName code:error.code userInfo:error.userInfo];
        [CrashlyticsKit recordError:newError];
        DBLog(@"Network error at: %@\n-----------------%@\n-----------",domainName,error);
    }
}

+ (void)recordError:(NSError *)error withCustomDomainName:(NSString *)customDomainName {
    BOOL hasValidError = [error isKindOfClass:[NSError class]] && customDomainName;
    if (hasValidError) {
        NSError *newError = [NSError errorWithDomain:customDomainName code:error.code userInfo:error.userInfo];
        [CrashlyticsKit recordError:newError];
        DBLog(@"Network error at: %@\n-----------------%@\n-----------",customDomainName,error);
    }
}

+ (NSString *)stringForDomainName:(ERDomain)erDomainName {
    switch (erDomainName) {
        case UnspecifiedDomain:return @"UnspecifiedDomain";
        case GETCharities: return @"GETCharities";
        case GETRidersRiderID: return @"GETRidersRiderID";
        case GETUser: return @"GETUser";
        case GETPromoCode: return @"GETPromoCode";
        case GETDiscount: return @"GETDiscount";
        case GETCurrentRide: return @"GETCurrentRide";
        case GETActiveDrivers: return @"GETActiveDrivers";
        case GETRideByID: return @"GETRideByID";
        case GETVersion: return @"GETVersion";
        case GETVersionInvalid: return @"GETVersionInvalid";
        case GETSplitList: return @"GETSplitList";
        case GETSplitListInvalidData: return @"GETSplitListInvalidData";
        case GETRideEstimate: return @"GETRideEstimate";
        case GETRideMap: return @"GETRideMap";
        case GETRideListForStatus: return @"GETRideListForStatus";
        case GETRideListForStatusCharged: return @"GETRideListForStatusCharged";
        case GETSurgeAreas: return @"GETSurgeAreas";
        case GETTipSettings: return @"GETTipSettings";
        case GETDriversCarTypes: return @"GETDriversCarTypes";
        case GETCards: return @"GETCards";
        case GETRidersPayments:return @"GETRidersPayments";
        case GETDriverTypes:return @"GETDriverTypes";
        case GETGlobalConfiguration:return @"GetGlobalConfiguration";
        case GETGlobalConfigurationInvalidData: return @"GETGlobalConfigurationInvalidData";
        case GETIPAddress:return @"GETIPAddress";
        case GETCurrentCityConfiguration: return @"GETCurrentCityConfiguration";
        case GETCityDetail: return @"GETCityDetail";
        case GETDriverTerms: return @"GETDriverTerms";
        case GETShareTokenLiveETA: return @"GETShareTokenLiveETA";
        case GETRideSpecialFees:    return @"GETRideSpecialFees";
            
        case POSTSignupDriver: return @"POSTSignupDriver";
        case POSTLogin: return @"POSTLogin";
        case POSTSignupAvailability: return @"POSTSignupAvailability";
            
        case POSTCreateUser: return @"POSTCreateUser";
        case POSTFacebookRegister: return @"POSTFacebookRegister";
        case POSTFacebookLogin: return @"POSTFacebookLogin";
        case POSTRequestRide: return @"POSTRequestRide";
        case POSTSupport: return @"POSTSupport";
        case POSTPhotosProfile: return @"POSTPhotosProfile";
        case POSTDriversCarPhoto: return @"POSTDriversCarPhoto";
        case POSTSplitFareRequest: return @"POSTSplitFareRequest";
        case POSTSplitFareRespond: return @"POSTSplitFareRespond";
        case POSTPromo: return @"POSTPromo";
        case POSTCallRequest: return @"POSTCallRequest";
        case POSTMaskSMS: return @"POSTMaskSMS";
        case POSTPhoneVerificationRequest:  return @"POSTPhoneVerificationRequest";
        case POSTPhoneVerificationSubmit:   return @"POSTPhoneVerificationSubmit";
        case POSTDriversDocuments:          return @"POSTDriversDocuments";
            
        case PUTRateRide: return @"PUTRateRide";
        case PUTSaveProfile: return @"PUTSaveProfile";
        case PUTSetPrimaryCard: return @"PUTSetPrimaryCard";
        case PUTUpdateDestination: return @"PUTUpdateDestination";
        case PUTRidersRiderID: return @"PUTRidersRiderID";
        case PUTUpdateComments: return @"PUTUpdateComments";
            
        case DELETECard: return @"DELETECard";
        case DELETERideByID: return @"DELETERideByID";
        case DELETESplitFareByID: return @"DELETESplitFareByID";
        case GOOGLEReverseGeocode: return @"GOOGLEReverseGeocode";
        case GOOGLEGetRoute: return @"GOOGLEGetRoute";
        case APPLEReverseGeoCode: return @"APPLEReverseGeoCode";
        case FBLogin: return @"FBLogin";
        case FBGraph: return @"FBGraph";
        case TryLogin: return @"TryLogin";
        case URLInvalidImage: return @"URLInvalidImage";
        case STRIPECreateToken: return @"STRIPECreateToken";
        case SINCHVerify: return @"SINCHVerify";
        case WATCHCacheWithoutEmail: return @"WATCHCacheWithoutEmail";
        case WATCHNullRideID: return @"WATCHNullRideID";
        case WATCHUnknownRideStatus: return @"WATCHUnknownRideStatus";
        case WATCHNullCurrentLocation: return @"WATCHNullCurrentLocation";
        case WATCHNullStartAddress: return @"WATCHNullStartAddress";
        case WATCHNullEndAddress: return @"WATCHNullEndAddress";
        case WATCHNullRideRequestCarCategory: return @"WATCHNullRideRequestCarCategory";
    }
}

+ (BOOL)shouldRecordError:(NSError *)error forDomain:(ERDomain)erDomainName {
    //
    //  COMMON ERRORS
    //
    NSNumber *isCommonError = [self shouldRecordAsCommonError:error];
    if (isCommonError != nil) {
        return isCommonError.boolValue;
    };

    return YES;
}

/**
 *  return nil if not a common error
 *  return @(NO)  will avoid reporting
 *  return @(YES) will be reported as common error
 */
+ (NSNumber *)shouldRecordAsCommonError:(NSError *)error {
    BOOL noInternet = [@"The network connection was lost." isEqualToString:error.localizedDescription];
    switch (error.code) {
        case 0:
            if (noInternet) return @(NO);
        case -1005: //no internet
        case -1009:
            return @(NO);
        case -1003: //A server with the specified hostname could not be found.
        case -1011: //this issue happens when server is overloaded, and it affects a lot of requests
        case -1019: //a data connection cannot be established since a call is currently active.
        case -1020: //A data connection is not currently allowed.
        case -1200: //An SSL error has occurred and a secure connection to the server cannot be made.
            return @(YES);
        default:
            return nil;
    }
}

@end
