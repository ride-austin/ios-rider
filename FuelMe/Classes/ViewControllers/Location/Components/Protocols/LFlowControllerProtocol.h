//
//  LFlowControllerProtocol.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/4/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//
@class RADriverDataModel;
@class RARideDataModel;
@protocol LFlowControllerProtocol 

- (void)navigateToRoundUp;
- (void)navigateToContactDriver:(RADriverDataModel * _Nullable)driver sender:(UIButton *_Nonnull)sender;
- (void)navigateToGetFeedbackForRide:(RARideDataModel * _Nullable)ride orError:(NSError * _Nullable)error;
- (void)navigateToPaymentMethodList;
- (void)navigateToError:(id _Nullable)error;

@end

@class RACampaignDetail;
@class RACampaignProvider;
@protocol DiscountDetailNavigationProtocol

- (void)navigateToCampaignDetailWithID:(NSNumber * _Nonnull)campaignID;
@end

@protocol DriverInfoViewNavigationProtocol

- (void)navigateToSplitFare;
- (void)navigateToFullscreenFromImageView:(UIImageView *_Nonnull)imageView withOriginalFrame:(CGRect)originalFrame;
- (void)navigateToShareETAWithSender:(UIButton * _Nonnull)sender;

@end


@protocol RequestRideViewNavigationProtocol

- (void)navigateToPromotions;

@end

@protocol SideMenuProtocol

- (void)showSideMenu;
- (void)hideSideMenu;

@end
