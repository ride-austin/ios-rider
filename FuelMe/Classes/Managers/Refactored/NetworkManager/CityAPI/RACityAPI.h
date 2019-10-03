//
//  RACityAPI.h
//  Ride
//
//  Created by Roberto Abreu on 24/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseAPI.h"
#import "RACityDetail.h"

@interface RACityAPI : RABaseAPI

+ (void)getCityDetailWithId:(NSNumber *)cityId withCompletion:(void (^)(RACityDetail *cityDetail, NSError *error))handler;

@end
