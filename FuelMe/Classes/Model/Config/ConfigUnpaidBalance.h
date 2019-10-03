//
//  ConfigUnpaidBalance.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigUnpaidBalance : RABaseDataModel

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSString *warningMessage;
@property (nonatomic, readonly) NSURL *iconSmallURL;
@property (nonatomic, readonly) NSURL *iconLargeURL;

@end
