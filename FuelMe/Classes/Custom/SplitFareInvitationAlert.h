//
//  SplitFareInvitationAlert.h
//  Ride
//
//  Created by Abdul Rehman on 31/08/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contact.h"
#import "SplitFareManagerDefines.h"

typedef void (^SplitFareActionBlock) (NSString *splitFareId, BOOL isAccepted);

@interface SplitFareInvitationAlert : UIView

@property (nonatomic, strong) NSString *splitFareId;
@property (nonatomic, strong) NSString *rideId;

+ (SplitFareInvitationAlert*)splitPopupWithContact:(Contact*)contact pushType:(SFPushType)pushType completion:(SplitFareActionBlock)handler;
- (void)show;

@end
