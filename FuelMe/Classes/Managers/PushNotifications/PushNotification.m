//
//  PushNotification.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PushNotification.h"

#import "NSNotificationCenterConstants.h"

@implementation PushNotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"aps"            : @"aps",
      @"eventKey"       : @"eventKey",
      @"paymentStatus"  : @"paymentStatus",
      @"requestId"      : @"requestId",
      @"rideId"         : @"rideId",
      @"title"          : @"title",
      @"splitFareId"    : @"splitFareId",
      @"sourceUserPhoto": @"sourceUserPhoto",
      @"sourceUser"     : @"sourceUser"
      };
}

- (PushEventType)eventType {
    NSDictionary *eventKeys =
    @{
      @"NO_AVAILABLE_DRIVER"    : @(PushEventTypeNoAvailableDriver),
      @"DRIVER_ASSIGNED"        : @(PushEventTypeDriverAssigned),
      @"DRIVER_REACHED"         : @(PushEventTypeDriverReached),
      @"DRIVER_CANCELLED"       : @(PushEventTypeDriverCancelled),
      @"RIDE_ACTIVE"            : @(PushEventTypeRideActive),
      @"RIDE_COMPLETED"         : @(PushEventTypeRideCompleted),
      @"RATE_REMINDER"          : @(PushEventTypeRateReminder),
      @"PAYMENT_STATUS_CHANGED" : @(PushEventTypePaymentStatusChanged),
      @"RIDE_REDISPATCHED"      : @(PushEventTypeRideRedispatched),
      @"SPLIT_FARE_ACCEPTED"    : @(PushEventTypeSplitFareAccepted),
      @"SPLIT_FARE_DECLINED"    : @(PushEventTypeSplitFareDeclined),
      @"SPLIT_FARE"             : @(PushEventTypeSplitFareRequested),
      @"RIDE_UPGRADE"           : @(PushEventTypeRideUpgrade)
      };
    NSNumber *eventType = eventKeys[self.eventKey];
    if (eventType) {
        return (PushEventType)eventType.integerValue;
    } else {
        if (self.eventKey) {
            NSAssert(eventType, @"eventKey %@ is not handled", self.eventKey);
        }
        return PushEventTypeUnknown;
    }
}

- (NSString *)splitFareNotificationName {
    switch (self.eventType) {
        case PushEventTypeSplitFareAccepted: return kNotificationSplitFareAccepted;
        case PushEventTypeSplitFareDeclined: return kNotificationSplitFareDeclined;
        case PushEventTypeSplitFareRequested:return kNotificationSplitFareRequested;
            
        case PushEventTypeNoAvailableDriver:
        case PushEventTypeDriverAssigned:
        case PushEventTypeDriverCancelled:
        case PushEventTypeDriverReached:
        case PushEventTypeRideActive:
        case PushEventTypeRideCompleted:
        case PushEventTypeRateReminder:
        case PushEventTypePaymentStatusChanged:
        case PushEventTypeRideRedispatched:
        case PushEventTypeRideUpgrade:
        case PushEventTypeUnknown:
            return nil;
    }
}

@end
