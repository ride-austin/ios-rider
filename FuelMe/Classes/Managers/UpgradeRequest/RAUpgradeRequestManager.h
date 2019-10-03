//
//  RAUpgradeRequestManager.h
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideStatus.h"
#import "RARideUpgradeRequestDataModel.h"

@interface RAUpgradeRequestManager : NSObject

+ (RAUpgradeRequestManager*)sharedManager;
- (void)showOrHidePopUpForUpgradeRequest:(RARideUpgradeRequestDataModel*)upgradeRequest andRide:(NSString*)ride;

@end

@interface RAUpgradeRequestManager (RideStatus)

+ (void)didChangeRideStatus:(RARideStatus)rideStatus;

@end
