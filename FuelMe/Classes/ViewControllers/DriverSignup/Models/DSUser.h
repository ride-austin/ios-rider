//
//  DSUser.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSAddress.h"

#import <Mantle/Mantle.h>

@interface DSUser : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSDate *dateOfBirth;
@property (nonatomic) DSAddress *address;
@property (nonatomic) NSString *firstname;
@property (nonatomic) NSString *lastname;
@property (nonatomic) NSString *middleName;

- (NSString *)fullName;
- (BOOL)isValid;

@end
