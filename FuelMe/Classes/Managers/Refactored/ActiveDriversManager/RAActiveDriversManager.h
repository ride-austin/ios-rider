//
//  RAActiveDriversManager.h
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAActiveDriverDataModel.h"
#import "RAActiveDriversRequest.h"

typedef void(^RAActiveDriversBlock)(NSArray<RAActiveDriverDataModel*> *activeDrivers, NSURL *categoryMapIconURL, NSError *error);

@interface RAActiveDriversManager : NSObject

@property(nonatomic, readonly, getter=isPolling) BOOL polling;

+ (RAActiveDriversManager*)sharedManager;

- (void)startPollingWithRequest:(RAActiveDriversRequest*)request andCompletion:(RAActiveDriversBlock)callback;
- (void)stopPolling;
- (void)updateRequest:(RAActiveDriversRequest*)request;

@end
