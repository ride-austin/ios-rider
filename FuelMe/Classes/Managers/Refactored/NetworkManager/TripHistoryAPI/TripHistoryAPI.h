//
//  TripHistoryAPI.h
//  Ride
//
//  Created by Robert on 8/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"
#import "TripHistoryDataModel.h"

typedef void(^TripHistoryCompletion)(NSArray<TripHistoryDataModel*> *tripHistories, NSInteger numberOfElements,NSError *error);

@interface TripHistoryAPI : RABaseAPI

+ (void)getTripHistoryWithRiderId:(NSString*)riderId limit:(NSNumber*)limit offset:(NSNumber*)page completion:(TripHistoryCompletion)handler;

@end
