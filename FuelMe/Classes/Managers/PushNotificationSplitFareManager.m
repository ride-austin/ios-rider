//
//  PushNotificationManager.m
//  Ride
//
//  Created by Abdul Rehman on 19/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PushNotificationSplitFareManager.h"

#import "ConfigurationManager.h"
#import "Contact.h"
#import "PushNotification.h"
#import "RAJSONAdapter.h"
#import "RASessionManager.h"
#import <Crashlytics/Crashlytics.h>
#import "RAAlertManager.h"
@import Firebase;

@interface PushNotificationSplitFareManager()
@property (nonatomic) NSMutableArray *notifications;
@end

@implementation PushNotificationSplitFareManager

+ (PushNotificationSplitFareManager*)sharedManager{
    static PushNotificationSplitFareManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PushNotificationSplitFareManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _notifications = [NSMutableArray new];
    }
    return self;
}

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [self.notifications addObject:notification];
    }
}

- (void)handleIfAppWasLaunchedByRemoteNotification {
    for (NSDictionary * notification in self.notifications) {
        [self didLaunchWithRemoteNotification:notification];
    }
    [self.notifications removeAllObjects];
}

- (void)didLaunchWithRemoteNotification:(NSDictionary*)userInfo{
    PushNotification *push = [RAJSONAdapter modelOfClass:PushNotification.class fromJSONDictionary:userInfo isNullable:NO];
    switch (push.eventType) {
        case PushEventTypeSplitFareAccepted:
        case PushEventTypeSplitFareDeclined: {
            Contact *contact = [[Contact alloc] initWithTargetContact:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:push.splitFareNotificationName object:contact];
        }
            //handle
            break;
            
        case PushEventTypeSplitFareRequested:
            //handled by splitFareManager checkMissedSplitFareRequests
            break;
            
        case PushEventTypeNoAvailableDriver:
        case PushEventTypeDriverAssigned:
        case PushEventTypeDriverCancelled:
        case PushEventTypeRideRedispatched:
        case PushEventTypeRideUpgrade:
        case PushEventTypePaymentStatusChanged:
        case PushEventTypeRateReminder:
        case PushEventTypeRideActive:
        case PushEventTypeDriverReached:
        case PushEventTypeRideCompleted:
            //DO NOTHING
            break;
        case PushEventTypeUnknown:
            //show message
            if ([push.aps.alert isKindOfClass:[NSString class]]) {
                
                [FIRAnalytics logEventWithName:@"PushReceived"
                                    parameters:@{@"message":push.aps.alert}];
               
                [RAAlertManager showAlertWithTitle:NSLocalizedString([ConfigurationManager appName], @"") message:push.aps.alert options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
            }
            break;
    }
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    PushNotification *push = [RAJSONAdapter modelOfClass:PushNotification.class fromJSONDictionary:userInfo isNullable:NO];
    switch (push.eventType) {
        case PushEventTypeSplitFareAccepted:
        case PushEventTypeSplitFareDeclined: {
            Contact *contact = [[Contact alloc] initWithTargetContact:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:push.splitFareNotificationName object:contact];
        }
            break;
        case PushEventTypeSplitFareRequested:
            [[NSNotificationCenter defaultCenter] postNotificationName:push.splitFareNotificationName object:nil];
            break;
            
        case PushEventTypeNoAvailableDriver:
        case PushEventTypeDriverAssigned:
        case PushEventTypeDriverCancelled:
        case PushEventTypeRideRedispatched:
        case PushEventTypeRideUpgrade:
        case PushEventTypeRideCompleted: //RA-15114
            //DO NOTHING
            break;
            
        case PushEventTypePaymentStatusChanged:
            //reload payment
            [[RASessionManager sharedManager] reloadCurrentRiderWithCompletion:nil];
            break;
            
        case PushEventTypeRateReminder:
        case PushEventTypeRideActive:
        case PushEventTypeDriverReached:
            //show message
            [FIRAnalytics logEventWithName:@"PushReceived"
                                parameters:@{@"eventKey":push.eventKey}];
            [RAAlertManager showAlertWithTitle:NSLocalizedString([ConfigurationManager appName], @"") message:push.aps.alert options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
            break;
            
        case PushEventTypeUnknown:
            //show message
            if ([push.aps.alert isKindOfClass:[NSString class]]) {
                [FIRAnalytics logEventWithName:@"PushReceived"
                                    parameters:@{@"message":push.aps.alert}];
                [RAAlertManager showAlertWithTitle:NSLocalizedString([ConfigurationManager appName], @"") message:push.aps.alert options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
            }
            break;
    }
}

@end
