//
//  RADesignatedPickup.h
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"
#import "RACoordinate.h"

/**
 Designated pickup or dropoff
 */
@interface RADesignatedPickup : RABaseDataModel

@property (nonatomic, nonnull, readonly) NSString *name;
@property (nonatomic, nonnull, readonly) RACoordinate *driverCoord;

@end
