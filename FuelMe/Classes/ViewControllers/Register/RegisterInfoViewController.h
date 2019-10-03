//
//  RegisterInfoViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/24/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@class RegisterInfoViewController;
@protocol RegisterInfoViewControllerDelegate
- (void)registerInfoViewControllerDidRegisterSuccessfullyWithFacebook:(RegisterInfoViewController *)registerInfoViewController;
- (void)registerInfoViewControllerDidVerify:(NSString *)phone
                                      email:(NSString *)email
                                   password:(NSString *)password;
@end

@class RAUserDataModel;

@interface RegisterInfoViewController : BaseViewController<UITextFieldDelegate>

/**
 contains email and password when new user without phone number logs in with facebook then proceeds to signup
 */
@property (nonatomic) RAUserDataModel *fbUser;
@property (nonatomic, weak) id<RegisterInfoViewControllerDelegate> delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)doNext:(id)sender;
- (IBAction)doFacebook:(id)sender;

@end
