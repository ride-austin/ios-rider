//
//  RARideStatus.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

/*
 * Ride statuses
 *   REQUESTED,
 *   RIDER_CANCELLED,
 *   DRIVER_ASSIGNED,
 *   DRIVER_CANCELLED,
 *   DRIVER_REACHED,
 *   ACTIVE,
 *   NO_AVAILABLE_DRIVER,
 *   COMPLETED,
 *   ADMIN_CANCELLED
 */

typedef NS_ENUM(NSInteger,RARideStatus){
    RARideStatusUnknown = 0,    // This one doesn't come from server, it is needed for any new status added on server but not implemented here.
    RARideStatusNone,           // This one doesn't come from server, it is only used to perform UI changes.
    RARideStatusPrepared,       // This one doesn't come from server, it is only used to distinguish it from RARideStatusRequested externally.
    RARideStatusRequesting,     // This one doesn't come from server, it is only used to perform UI changes externally.
    RARideStatusRequested,
    RARideStatusNoAvailableDriver,
    RARideStatusRiderCancelled,
    RARideStatusDriverCancelled,
    RARideStatusAdminCancelled,
    RARideStatusDriverAssigned,
    RARideStatusDriverReached,
    RARideStatusActive,
    RARideStatusCompleted
};
