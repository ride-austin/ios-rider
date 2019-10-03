//
//  NSObject+QueueName.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (QueueName)

+ (NSString *)queueName;
+ (NSString *)serialClientName;

@end
