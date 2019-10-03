//
//  UIViewController+progressHUD.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+SVProgressHUD.h"

@interface UIViewController (progressHUD)

- (void)showSuccessHUDandPOP;
- (void)showSuccessHUDAndPopWithStatus:(NSString* _Nonnull)status;

@end
