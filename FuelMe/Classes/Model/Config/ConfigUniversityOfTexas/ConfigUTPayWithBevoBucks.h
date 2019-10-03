//
//  ConfigUTPayWithBevoBucks.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigUTPayWithBevoBucks : RABaseDataModel

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly, nonnull, copy) NSURL *iconLargeUrl;
@property (nonatomic, readonly, nonnull, copy) NSNumber *ridePaymentDelay;
@property (nonatomic, readonly, nonnull, copy) NSString *shortDescription;

/**
 if availableForSplitfare == NO, show splitfareMessage
 */
@property (nonatomic, readonly, nonnull, copy) NSString *splitfareMessage;
@property (nonatomic, readonly) BOOL availableForSplitfare;
@end
