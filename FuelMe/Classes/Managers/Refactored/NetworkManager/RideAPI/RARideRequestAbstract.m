//
//  RARideRequestAbstract.m
//  Ride
//
//  Created by Roberto Abreu on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//
#import "RAMacros.h"
#import "RARideRequestAbstract.h"
#import "ErrorReporter.h"

static NSString *const kJSONStartLocationLatitude   = @"startLocationLat";
static NSString *const kJSONStartLocationLongitude  = @"startLocationLong";
static NSString *const kJSONStartLocationAddress    = @"startAddress";
static NSString *const kJSONStartLocationZip        = @"startZipCode";
static NSString *const kJSONInSurgeArea             = @"inSurgeArea";
static NSString *const kJSONCarCategory             = @"carCategory";
static NSString *const kJSONApplePayToken           = @"applePayToken";
static NSString *const kJSONPaymentProvider         = @"paymentProvider";

@implementation RARideRequestAbstract

- (NSDictionary *)jsonDictionary {
    NSMutableDictionary *jsonResponse = [[NSMutableDictionary alloc] init];
    
    // Start location
    NSString *startLatitude = [NSString stringWithFormat:@"%f",self.startLocation.latitude.doubleValue];
    jsonResponse[kJSONStartLocationLatitude] = startLatitude;
    NSString *startLongitude = [NSString stringWithFormat:@"%f",self.startLocation.longitude.doubleValue];
    jsonResponse[kJSONStartLocationLongitude] = startLongitude;
    NSString *startAddress = self.startLocation.completeAddress;
    BOOL startAddressIsString = [startAddress isKindOfClass:[NSString class]];
    if (!startAddressIsString) {
        startAddress = @"";
    }
    jsonResponse[kJSONStartLocationAddress] = startAddress;
    NSString *startZipCode = self.startLocation.zipCode;
    if (IS_EMPTY(startZipCode)) {
        startZipCode = @"00000";
    }
    jsonResponse[kJSONStartLocationZip] = startZipCode;
    
    //Surge Area
    NSString *inSurgeAreaString = self.carCategory.hasPriority ? @"true" : @"false";
    jsonResponse[kJSONInSurgeArea] = inSurgeAreaString;
    
    // Car Category
    NSString *carCategory = self.carCategory.carCategory;
    if (IS_EMPTY(carCategory)) {
        carCategory = @"REGULAR";
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"carCategoryObject"] = self.carCategory;
        [ErrorReporter recordErrorDomainName:WATCHNullRideRequestCarCategory
                                withUserInfo:userInfo];
    }
    jsonResponse[kJSONCarCategory] = carCategory;
    
    if (!startAddressIsString) {
        [ErrorReporter recordErrorDomainName:WATCHNullStartAddress withUserInfo:jsonResponse];
    }
    
    if (self.applePayToken) {
        jsonResponse[kJSONApplePayToken] = self.applePayToken;
    } else {
        jsonResponse[kJSONPaymentProvider] = self.paymentProvider;
    }
    
    return jsonResponse;
}

- (void)cleanupApplePayToken {
    self.applePayToken = nil;
}

@end
