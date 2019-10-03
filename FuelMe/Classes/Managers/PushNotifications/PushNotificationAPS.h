//
//  PushNotificationAPS.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PushNotificationAPS : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *alert;
@property (nonatomic, copy, readonly) NSString *sound;

@end
