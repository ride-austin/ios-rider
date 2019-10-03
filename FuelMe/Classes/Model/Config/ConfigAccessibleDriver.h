//
//  ConfigAccessibleDriver.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigAccessibleDriver : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL isEnabled;
@property (nonatomic, nullable) NSString *phoneNumber;
@property (nonatomic, nullable) NSString *title;

@end
