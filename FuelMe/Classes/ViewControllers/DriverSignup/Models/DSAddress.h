//
//  DSAddress.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface DSAddress : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *address;
@property (nonatomic) NSString *zipCode;

- (BOOL)isValid;

@end
