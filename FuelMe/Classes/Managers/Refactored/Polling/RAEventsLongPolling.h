//
//  RALongPolling.h
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAEventDataModel.h"

extern NSString *kEventsLongPollingHasReceivedNewEventNotification;

@interface RAEventsLongPolling : NSObject

+ (RAEventsLongPolling*)sharedManager;

@end
