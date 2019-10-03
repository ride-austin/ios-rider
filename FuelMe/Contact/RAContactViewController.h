//
//  RAContactViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/3/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@interface RAContactViewController : BaseViewController
@property (nonatomic, nonnull) NSString *driverFirstName;
@property (nonatomic, nonnull, copy) void(^didTapSMSBlock)(void);
@end
