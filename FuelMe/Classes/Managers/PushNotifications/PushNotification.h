//
//  PushNotification.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PushNotificationAPS.h"

#import <Mantle/Mantle.h>

/**
 - PushEventTypeUnknown: when eventKey is nil or not handled. Message from console has nil eventKey
 */
typedef NS_ENUM(NSUInteger, PushEventType) {
    PushEventTypeUnknown = 0,
    PushEventTypeNoAvailableDriver,
    PushEventTypeDriverAssigned,
    PushEventTypeDriverCancelled,
    PushEventTypeDriverReached,
    PushEventTypeRideActive,
    PushEventTypeRideCompleted,
    PushEventTypeRateReminder,
    PushEventTypePaymentStatusChanged,
    PushEventTypeRideRedispatched,
    PushEventTypeSplitFareAccepted,
    PushEventTypeSplitFareDeclined,
    PushEventTypeSplitFareRequested,
    PushEventTypeRideUpgrade
};

@interface PushNotification : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy, readonly) PushNotificationAPS *aps;
@property (nonatomic, copy, readonly) NSString *eventKey;

@property (nonatomic, copy, readonly) NSString *paymentStatus; //PAID or XXX
@property (nonatomic, copy, readonly) NSString *requestId;
@property (nonatomic, copy, readonly) NSString *rideId;
@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) NSString *splitFareId;
@property (nonatomic, copy, readonly) NSURL *sourceUserPhoto;
@property (nonatomic, copy, readonly) NSString *sourceUser;

- (PushEventType)eventType;
- (NSString *)splitFareNotificationName;

@end
