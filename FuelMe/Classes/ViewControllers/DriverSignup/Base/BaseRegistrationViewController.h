//
//  BaseRegistrationViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/5/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

#import "ConfigRegistration.h"
@class DSFlowController;

@interface BaseRegistrationViewController : BaseViewController
@property (weak, nonatomic) DSFlowController *coordinator;
- (ConfigRegistration *)regConfig;
- (BOOL)isImageValid:(UIImage *)image;

@end
