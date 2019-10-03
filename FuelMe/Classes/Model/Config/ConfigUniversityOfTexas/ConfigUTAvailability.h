//
//  ConfigUTAvailability.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigUTAvailability : RABaseDataModel

@property (nonatomic, readonly, nonnull, copy) NSString *from;
@property (nonatomic, readonly, nonnull, copy) NSString *to;

@end
