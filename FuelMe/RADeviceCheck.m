//
//  RADeviceCheck.m
//  Ride
//
//  Created by Roberto Abreu on 10/31/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RADeviceCheck.h"

#import <SAMKeychain/SAMKeychain.h>

static NSString *const service = @"deviceIdentifier";
static NSString *const acccount = @"com.rideaustin";

@implementation RADeviceCheck

+ (NSString *)deviceIdentifier {
    [SAMKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];
    NSString *identifier = [SAMKeychain passwordForService:service account:acccount];
    if (!identifier) {
        identifier = [[NSUUID UUID] UUIDString];
        [SAMKeychain setPassword:identifier forService:service account:acccount];
    }
    return identifier;
}

@end
