//
//  ConfigCancellationFeedback.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/28/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "ConfigCancellationFeedback.h"
#import "NSDate+Utils.h"

@implementation ConfigCancellationFeedback

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"enabled"        : @"enabled",
             @"cancellationThreshold" : @"cancellationThreshold"
             };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cancellationThreshold = @(60);
    }
    return self;
}

- (BOOL)shouldShowFeedbackForRideWithAcceptedDate:(NSDate *)driverAcceptedDate {
    return self.enabled && [[NSDate trueDate] compare:[driverAcceptedDate dateByAddingTimeInterval:self.cancellationThreshold.doubleValue]] == NSOrderedDescending;
}

@end
