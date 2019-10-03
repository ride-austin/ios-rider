//
//  NSObject+QueueName.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSObject+QueueName.h"

@implementation NSObject (QueueName)

+ (NSString *)queueName {
    return [NSString stringWithFormat:@"QueueTypeSerial%@",NSStringFromClass([self class])];
}

+ (NSString *)serialClientName {
    return [NSString stringWithFormat:@"SerialClient%@",NSStringFromClass([self class])];
}

@end
