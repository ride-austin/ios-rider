//
//  BaseViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/25/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "ConfigurationManager.h"
#import "NSObject+className.h"
#import "NSString+AlertTitle.h"
#import "RANetworkManager.h"
#import "RAPhotoPickerControllerManager.h"
#import "RASessionManager.h"
#import "RecipientTypes.h"
#import "RideConstants.h"
#import "DNA.h"
#import "SystemVersionCompare.h"
#import "UIBarButtonItem+RAFactory.h"
#import "UIViewController+progressHUD.h"
#import "UIView+CompatibleAnchor.h"
#import "GAI.h"
#import "GAITrackedViewController.h"
#import "KLCPopup.h"
#import "RAAlertManager.h"


@interface BaseViewController : GAITrackedViewController

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, assign) BOOL isAlertShowing;

- (void)configureAllTapsWillDismissKeyboard;
- (void)dismissKeyboard;
- (void)addChildViewController:(UIViewController*)controller withContainer:(UIView*)container;

@end

@interface BaseViewController (Tracker)

- (void)trackButtonUI:(NSString*)label;

@end

@interface BaseViewController (SendMessage) <MFMailComposeViewControllerDelegate>

- (void)showMessageViewWithRideID:(NSString  * _Nullable)rideID cityID:(NSNumber  * _Nullable)cityID;
- (void)showSupportEmail:(UIBarButtonItem *)sender;

@end

NS_ASSUME_NONNULL_END

