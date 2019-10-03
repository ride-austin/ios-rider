//
//  DSDriver.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSUser.h"

#import <Mantle/Mantle.h>

@interface DSDriver : MTLModel <MTLJSONSerializing>

@property (nonatomic, nullable) NSNumber *modelID;
@property (nonatomic) DSUser *user;
@property (nonatomic) NSString *licenseNumber;
@property (nonatomic) NSString *licenseState;
@property (nonatomic) NSDate *licenseExpiryDate;
@property (nonatomic) NSDate *insuranceExpiryDate;
@property (nonatomic) NSString *ssn;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic) NSNumber *cityId;

- (instancetype)initWithEmail:(NSString *)email;
- (BOOL)isValid;

@end
