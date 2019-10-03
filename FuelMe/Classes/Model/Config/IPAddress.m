//
//  IPAddress.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "IPAddress.h"

@implementation IPAddress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"lon":@"lon",
              @"lat":@"lat",
              @"city":@"city",
            };
}

- (CLLocation*)location {
    if ([self.lat isKindOfClass:[NSNumber class]] && [self.lon isKindOfClass:[NSNumber class]]) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.lat.doubleValue longitude:self.lon.doubleValue];
        return loc;
    }
    return nil;
}

@end
/*
 sample response
 
 "lon" : 55.3047,
 "zip" : "",
 "query" : "80.227.151.186",
 "as" : "AS15802 Emirates Integrated Telecommunications Company PJSC (EITC-DU)",
 "countryCode" : "AE",
 "isp" : "Emirates Integrated Telecommunications Company PJS",
 "lat" : 25.2582,
 "city" : "Dubai",
 "region" : "DU",
 "timezone" : "Asia\/Dubai",
 "org" : "Emirates Integrated Telecommunications Company PJS",
 "country" : "United Arab Emirates",
 "regionName" : "Dubai",
 "status" : "success"
 */
