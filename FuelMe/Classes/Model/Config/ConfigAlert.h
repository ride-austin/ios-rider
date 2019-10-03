//
//  ConfigAlert.h
//  Ride
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigAlert : RABaseDataModel

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly, nullable) NSString *message;
@property (nonatomic, readonly, nullable) NSString *actionTitle;
@property (nonatomic, readonly, nullable) NSString *cancelTitle;

@end
