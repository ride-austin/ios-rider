//
//  DBRideStubConfiguration.h
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockRideResponseModel.h"
#import "DBRideStubInjection.h"

@interface DBRideStubConfiguration : NSObject

@property (nonatomic) NSInteger initialTime; // Time to start ride at --> used in `rideDictionaryAtTime:` Negative value will respond with empty ride
@property (nonatomic, strong) NSArray<NSString*> *resourceFiles;   // JSON files from where to retrieve data. It will be taken in order for ride resubmission, after ride cancelled.
@property (nonatomic) MockRideStatus statusBeforeCancelled; // If ride is cancelled, this status will be sent just before cancelled time arrives. Should be MockRideStatusDriverReached or MockRideStatusDriverAssigned. Default is: MockRideStatusDriverReached.
@property (nonatomic) MockRideStatus whoCancells; // If ride is cancelled, this status will be sent when cancelled time arrives. Should be MockRideStatusCancelledByDriver or MockRideStatusCancelledByRider. Default is: MockRideStatusCancelledByDriver.
@property (nonatomic, strong) NSArray<DBRideStubInjection*> *injections;

@end
