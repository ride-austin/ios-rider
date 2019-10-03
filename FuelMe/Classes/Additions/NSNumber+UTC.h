//
//  NSNumber+UTC.h
//  Ride
//
//  Created by Kitos on 16/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (UTC)

- (NSDate*)dateFromUTC;

+ (NSNumber*)UTCFromDate:(NSDate*)date;

@end
