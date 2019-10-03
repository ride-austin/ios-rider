//
//  UnpaidBalance.m
//  Ride
//
//  Created by Roberto Abreu on 8/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAUnpaidBalance.h"

@implementation RAUnpaidBalance

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"rideId" : @"rideId",
              @"amount" : @"amount",
              @"bevoBucksUrl" : @"bevoBucksUrl",
              @"willChargeOn" : @"willChargeOn",
            };
}

@end

@implementation RAUnpaidBalance (Display)

- (NSString *)displayAmount {
    return [NSString stringWithFormat:@"$%@",self.amount];
}

@end
