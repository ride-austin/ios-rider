//
//  UnratedRideManager.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UnratedRide;

@interface UnratedRideManager : NSObject

@property (nonatomic) NSNumber *tipLimit;

+ (instancetype)shared;
+ (NSString *)checkRideToRate;
+ (void)checkForRatedRides;
+ (void)addUnratedRide:(NSString *)rideID;
+ (void)addRideToSubmit:(UnratedRide *)unsubmittedRide;

@end
