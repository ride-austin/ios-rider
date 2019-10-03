//
//  RAActiveDriversAPI.h
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"

#import "RAActiveDriverDataModel.h"
#import "RAActiveDriversRequest.h"

typedef void(^RAActiveDriversAPICompletionlock)(NSArray<RAActiveDriverDataModel *> *activeDrivers,NSURL *categoryMapIconURL, NSError *error);

@interface RAActiveDriversAPI : RABaseAPI

+ (void)getActiveDrivers:(RAActiveDriversRequest*)activeDriversRequest withCompletion:(RAActiveDriversAPICompletionlock)handler;

@end
