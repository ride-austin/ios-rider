//
//  PasswordViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 11/11/12.
//  Copyright (c) 2012 FuelMe. All rights reserved.
//

#import "BaseViewController.h"

@class PaddedTextField;

@interface PasswordViewController : BaseViewController<UITextFieldDelegate>

@property(nonatomic, retain) IBOutlet PaddedTextField* password;
@property(nonatomic, retain) IBOutlet PaddedTextField* confirmPassword;

@end
