//
//  DriverPhotoViewController.h
//  Ride
//
//  Created by Carlos Alcala on 9/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"

@interface DriverPhotoViewController : BaseRegistrationViewController

@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) UIImage *photo;

- (IBAction)takePhotoAction:(id)sender;

@end
