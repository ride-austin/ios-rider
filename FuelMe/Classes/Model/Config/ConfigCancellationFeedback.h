//
//  ConfigCancellationFeedback.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/28/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigCancellationFeedback : MTLModel <MTLJSONSerializing>

/**
 After cancellationThreshold, you may display the cancellationFeedback
 */
@property (nonatomic, nonnull) NSNumber *cancellationThreshold;
@property (nonatomic) BOOL enabled;

- (BOOL)shouldShowFeedbackForRideWithAcceptedDate:(NSDate * _Nonnull)acceptedDate;
@end
