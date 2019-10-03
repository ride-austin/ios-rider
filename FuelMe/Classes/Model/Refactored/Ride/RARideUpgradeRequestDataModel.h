//
//  RARideUpgradeRequestDataModel.h
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger, RARideUpgradeRequestStatus) {
    RAURSUnknown = 0,
    RAURSRequested,
    RAURSExpired,
    RAURSAccepted,
    RAURSDeclined,
    RAURSCancelled
};

@interface RARideUpgradeRequestDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSNumber *surgeFactor;
@property (nonatomic) RARideUpgradeRequestStatus upgradeStatus;

@end
