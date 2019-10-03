//
//  MessageFlowControllerProtocol.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/11/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InsertingProtocol.h"
@class RACampaign;
@protocol MessageFlowControllerProtocol

- (void)showCampaignMessage:(RACampaign *)campaign inViewController:(UIViewController<InsertingProtocol> * _Nonnull)viewController;
- (void)hideCampaignMessage;
- (void)showStackedRideInfoInViewController:(UIViewController<InsertingProtocol> * _Nonnull)viewController;
- (void)hideStackedRideInfo;
- (void)showPaymentDeficiencyInViewController:(UIViewController<InsertingProtocol> *_Nonnull)viewController;

@end
