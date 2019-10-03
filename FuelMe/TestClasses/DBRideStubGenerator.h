//
//  DBRideStubGenerator.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockRideResponseModel.h"
#import "DBRideStubInjection.h"

@class DBRideStubConfiguration;

@interface DBRideStubGenerator : NSObject

@property (nonatomic, assign) MockRideStatus forceRideMockStatus;

+ (instancetype)shared;
- (void)configureData;
- (NSDictionary *)rideDictionaryAtTime:(NSUInteger)time;
+ (NSNumber *)rideID;
+ (CGFloat)speed;
- (void)addInjection:(DBRideStubInjection*)rideStubInjection;

@end
