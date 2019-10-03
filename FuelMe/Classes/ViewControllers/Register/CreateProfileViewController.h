//
//  CreateProfileViewController.h
//  Ride
//
//  Created by Tyson Bunch on 5/12/16
//  Copyright (c) 2016 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@class CreateProfileViewController;
@protocol CreateProfileViewControllerDelegate
- (void)createProfileViewControllerDidRegisterSuccessfully:(CreateProfileViewController *)createProfileViewController;
@end

@interface CreateProfileViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, weak) id<CreateProfileViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, strong) IBOutlet UIImageView *pictureView;

- (id)initWithEmail:(NSString*)email mobile:(NSString*)mobile password:(NSString*)password;
- (IBAction)editPicture:(id)sender;
- (IBAction)terms:(id)sender;
- (IBAction)privacy:(id)sender;
- (IBAction)launchweb:(id)sender;

@end
