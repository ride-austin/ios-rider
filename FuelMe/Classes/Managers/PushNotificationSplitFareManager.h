//
//  PushNotificationManager.h
//  Ride
//
//  Created by Abdul Rehman on 19/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationSplitFareManager : NSObject
+ (PushNotificationSplitFareManager*_Nonnull)sharedManager;
/**
 Receive remote notifications during app launch, and handled when delegate is ready
 */
- (void)didFinishLaunchingWithOptions:(NSDictionary * _Nullable)launchOptions;

- (void)handleIfAppWasLaunchedByRemoteNotification;
/**
 Receive remote notifications and handle immediately
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo;
@end
