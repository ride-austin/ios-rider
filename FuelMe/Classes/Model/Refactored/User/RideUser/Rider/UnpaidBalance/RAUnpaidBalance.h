//
//  UnpaidBalance.h
//  Ride
//
//  Created by Roberto Abreu on 8/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RAUnpaidBalance : RABaseDataModel

@property (strong, nonatomic) NSNumber *rideId;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSURL *bevoBucksUrl;
@property (strong, nonatomic) NSNumber *willChargeOn;

@end

@interface RAUnpaidBalance (Display)

- (NSString *)displayAmount;

@end
