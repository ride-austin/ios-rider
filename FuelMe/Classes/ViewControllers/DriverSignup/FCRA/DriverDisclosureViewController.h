//
//  DriverDisclosureViewController.h
//  Ride
//
//  Created by Abdul Rehman on 17/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"

@class FlatButton;

@interface DriverDisclosureViewController : BaseRegistrationViewController

@property (weak, nonatomic) IBOutlet UIButton *imgCheckBox;
@property (weak, nonatomic) IBOutlet FlatButton *btContinue;

@end
