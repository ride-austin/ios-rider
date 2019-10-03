//
//  RAPhoneVerificationAPI.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"

@interface RAPhoneVerificationAPI : RABaseAPI

#pragma mark - Phone Verification
+ (void)postVerifyPhoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(NSString *token, NSError *error))completion;
+ (void)postVerifyCode:(NSString *)code token:(NSString *)token withCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
