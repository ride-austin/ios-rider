//
//  RADirectConnectRideRequest.m
//  Ride
//
//  Created by Roberto Abreu on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RADirectConnectRideRequest.h"

static NSString *const kJSONDirectConnectId = @"directConnectId";
static NSString *const kJSONDriverType = @"driverType";
static NSString *const kJSONInSurgeArea = @"inSurgeArea";

@implementation RADirectConnectRideRequest

- (NSDictionary *)jsonDictionary {
    NSMutableDictionary *jsonResponse = [NSMutableDictionary dictionaryWithDictionary:[super jsonDictionary]];
    
    jsonResponse[kJSONDirectConnectId] = self.directConnectId;
    jsonResponse[kJSONDriverType] = @"DIRECT_CONNECT";
    
    NSString *inSurgeAreaString = self.hasSurgeArea ? @"true" : @"false";
    jsonResponse[kJSONInSurgeArea] = inSurgeAreaString;
    
    return jsonResponse;
}

@end
