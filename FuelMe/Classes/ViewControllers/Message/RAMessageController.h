//
//  RAMessageController.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/10/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InsertingProtocol.h"
@class RACampaign;
@interface RAMessageController : NSObject

- (instancetype _Nonnull)initWithNavigationController:(UINavigationController * _Nonnull)navigationController;
- (void)showCampaignMessage:(RACampaign *)campaign inViewController:(UIViewController<InsertingProtocol> * _Nonnull)viewController withDidTapBlock:(void(^_Nullable)(void))didTapBlock;
- (void)hideCampaignMessage;
- (void)showStackedRideInfoInViewController:(UIViewController<InsertingProtocol> * _Nonnull)viewController;
- (void)hideStackedRideInfo;
- (void)showPaymentDeficiencyMessage:(NSString *_Nonnull)message inViewController:(UIViewController<InsertingProtocol> *_Nonnull)viewController didTapBlock:(void(^_Nullable)(void))didTapBlock;
- (void)hidePaymentDeficiencyMessage;

@end
