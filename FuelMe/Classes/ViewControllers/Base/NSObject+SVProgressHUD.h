//
//  NSObject+SVProgressHUD.h
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SVProgressHUD)

- (void)showHUD;
- (void)showHUDForDuration:(NSTimeInterval)duration;
- (void)showConnectivityErrorHUD;
- (void)hideHUD;
- (void)hideHUDForError:(NSError * _Nullable)error;
- (void)hideHUD:(BOOL)isSuccess;
- (void)hideHUD:(BOOL)isSuccess status:(NSString* _Nonnull)status;
- (void)showSuccessHUDWithStatus:(NSString* _Nonnull)status;
- (void)showSuccessHUDWithStatus:(NSString* _Nonnull)status andDismissDelay:(NSTimeInterval)delay;
- (void)showSuccessHUDWithDismissDelay:(NSUInteger)delay;

@end
