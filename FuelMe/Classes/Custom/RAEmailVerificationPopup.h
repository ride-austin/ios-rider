//
//  RAEmailVerificationPopup.h
//  Ride
//
//  Created by Roberto Abreu on 11/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EmailVerificationStatus) {
    EmailVerifiedStatus,
    EmailUnverifiedStatus
};

@protocol RAEmailVerificationPopupDelegate

- (void)didTapSendEmailVerification;

@end

@interface RAEmailVerificationPopup : UIView

@property (weak, nonatomic) id<RAEmailVerificationPopupDelegate> delegate;

+ (instancetype)popupWithEmail:(NSString *)email delegate:(id<RAEmailVerificationPopupDelegate>)delegate showingState:(EmailVerificationStatus)emailVerificationStatus;

- (void)updateWithEmailVerificationStatus:(EmailVerificationStatus)emailVerificationStatus;
- (void)show;
- (void)dismiss;

@end
