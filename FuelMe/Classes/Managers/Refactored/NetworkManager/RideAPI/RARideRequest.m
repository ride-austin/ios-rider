//
//  RARideRequest.m
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAMacros.h"
#import "RARideRequest.h"
#import "RARideRequestManager.h"
#import "ErrorReporter.h"
#import "CLLocation+isValid.h"

static NSString *const kJSONEndLocationLatitude     = @"endLocationLat";
static NSString *const kJSONEndLocationLongitude    = @"endLocationLong";
static NSString *const kJSONEndLocationAddress      = @"endAddress";
static NSString *const kJSONEndLocationZip          = @"endZipCode";
static NSString *const kJSONDriverType              = @"driverType";
static NSString *const kJSONComment                 = @"comment";

@implementation RARideRequest

- (NSDictionary *)jsonDictionary {
    NSMutableDictionary *jsonResponse = [NSMutableDictionary dictionaryWithDictionary:[super jsonDictionary]];
    
    // End Location
    BOOL endAddressIsString = YES;
    CLLocationCoordinate2D endCoord = CLLocationCoordinate2DMake(self.endLocation.latitude.doubleValue, self.endLocation.longitude.doubleValue);
    if ([CLLocation isCoordinateNonZero:endCoord]) {
        NSString *endLatitude = [NSString stringWithFormat:@"%f",endCoord.latitude];
        jsonResponse[kJSONEndLocationLatitude] = endLatitude;
        NSString *endLongitude = [NSString stringWithFormat:@"%f",endCoord.longitude];
        jsonResponse[kJSONEndLocationLongitude] = endLongitude;
        NSString *endAddress = self.endLocation.completeAddress;
        endAddressIsString = [endAddress isKindOfClass:[NSString class]];
        if (!endAddressIsString) {
            endAddress = @"";
        }
        jsonResponse[kJSONEndLocationAddress] = endAddress;
        
        NSString *endZipCode = self.endLocation.zipCode;
        if (IS_EMPTY(endZipCode)) {
            endZipCode = @"00000";
        }
        jsonResponse[kJSONEndLocationZip] = endZipCode;
    }
    
    //Comment
    if (!IS_EMPTY(self.comment)) {
        jsonResponse[kJSONComment] = self.comment;
    }
    
    // Woman only mode
    NSMutableArray *modesArray = [NSMutableArray new];
    if ([self isWomanOnlyMode]) {
        [modesArray addObject:@"WOMEN_ONLY"];
    }
    
    // Fingerprinted Only Driver mode
    if ([RARideRequestManager sharedManager].isFingerprintedDriverOnlyModeOn) {
        [modesArray addObject:@"FINGERPRINTED"];
    }

    if (modesArray.count > 0) {
        NSString *driverTypeString = [modesArray componentsJoinedByString:@","];
        jsonResponse[kJSONDriverType] = driverTypeString;
    }

    if (!endAddressIsString) {
        [ErrorReporter recordErrorDomainName:WATCHNullEndAddress withUserInfo:jsonResponse];
    }
    
    return [NSDictionary dictionaryWithDictionary:jsonResponse];
}

@end

#import "RARideCommentsManager.h"

@implementation RARideRequest (Comments)

- (NSString *)cachedComment {
    if (self.startLocation) {
        return  [[RARideCommentsManager sharedManager] commentFromLocation:self.startLocation.coordinate];
    }
    return nil;
}

- (void)storeComment {
    if (self.startLocation) {
        [[RARideCommentsManager sharedManager] storeComment:self.comment forLocation:self.startLocation.coordinate];
    }
}

@end
