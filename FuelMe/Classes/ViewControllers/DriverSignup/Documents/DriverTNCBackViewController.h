//
//  DriverTNCBackViewController.h
//  Ride
//
//  Created by Carlos Alcala on 2/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseRegistrationViewController.h"

#import "KLCPopup.h"

@interface DriverTNCBackViewController : BaseRegistrationViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) IBOutlet UITextField *expirationDate;

@property (strong, nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) KLCPopup *datePopup;

@end
