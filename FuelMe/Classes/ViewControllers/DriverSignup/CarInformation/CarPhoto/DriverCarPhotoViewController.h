//
//  DriverCarFrontViewController.h
//  Ride
//
//  Created by Carlos Alcala on 9/21/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"
@class DSFlowController;
@interface DriverCarPhotoViewController : BaseRegistrationViewController

- (instancetype _Nonnull)initWithType:(CarPhotoType)carPhotoType andCoordinator:(DSFlowController * _Nonnull)coordinator;

@end
