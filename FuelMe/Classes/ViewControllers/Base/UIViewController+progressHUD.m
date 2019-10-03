//
//  UIViewController+progressHUD.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIViewController+progressHUD.h"

@implementation UIViewController (progressHUD)

- (void)showSuccessHUDandPOP {
    [self showSuccessHUDAndPopWithStatus:NSLocalizedString(@"SUCCESS", "")];
}

- (void)showSuccessHUDAndPopWithStatus:(NSString *)status {
    [self showSuccessHUDWithStatus:status];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}

@end
