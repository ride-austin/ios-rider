//
//  NSObject+SVProgressHUD.m
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSObject+SVProgressHUD.h"
#import "DNA.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation NSObject (SVProgressHUD)

- (void)showHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE WAIT...", "")];
}

- (void)showHUDForDuration:(NSTimeInterval)duration {
    [self showHUD];
    [SVProgressHUD dismissWithDelay:duration];
}

- (void)showConnectivityErrorHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"WAITING FOR INTERNET CONNECTION...", "")];
}

- (void)hideHUD {
    [SVProgressHUD dismiss];
}

- (void)hideHUDForError:(NSError*)error {
    return [self hideHUD:(error==nil)];
}

- (void)hideHUD:(BOOL)isSuccess {
    [self hideHUD:isSuccess status:@""];
}

- (void)hideHUD:(BOOL)isSuccess status:(NSString *)status {
    __weak __typeof__(self) weakSelf = self;
    [SVProgressHUD dismissWithCompletion:^{
        if (isSuccess) {
            [weakSelf showSuccessHUDWithStatus:status andDismissDelay:1.0];
        }
    }];
}

- (void)configureSuccessHUD {
    [SVProgressHUD setFont:[UIFont fontWithName:FontTypeLight size:13]];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"success-icon"]];
    [SVProgressHUD setCornerRadius:6];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setMinimumSize:CGSizeMake(156, 110)];
}

- (void)showSuccessHUDWithStatus:(NSString *)status {
    [self configureSuccessHUD];
    [SVProgressHUD showSuccessWithStatus:status]; //--> This One Dismiss After Time Interval
}

- (void)showSuccessHUDWithStatus:(NSString *)status andDismissDelay:(NSTimeInterval)delay {
    [self configureSuccessHUD];
    [SVProgressHUD setMinimumDismissTimeInterval:delay];
    [SVProgressHUD showSuccessWithStatus:status]; //--> This One Dismiss After Time Interval
}

- (void)showSuccessHUDWithDismissDelay:(NSUInteger)delay {
    [self showSuccessHUDWithStatus:NSLocalizedString(@"SUCCESS", "") andDismissDelay:delay];
}

@end
