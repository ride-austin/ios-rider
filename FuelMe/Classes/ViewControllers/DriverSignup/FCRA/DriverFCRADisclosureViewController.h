//
//  DriverFCRADisclosureViewController.h
//  Ride
//
//  Created by Carl von Havighorst on 7/6/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"

@interface DriverFCRADisclosureViewController : BaseRegistrationViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *confirmAcknowledgementCheckBoxButton;

@end
