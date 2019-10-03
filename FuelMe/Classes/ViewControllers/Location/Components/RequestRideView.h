//
//  RequestRideView.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "FemaleDriverModeDataSource.h"
#import "RACustomView.h"
#import "LFlowControllerProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@class RequestRideView, RARideRequestManager;
@protocol RequestRideViewDelegate <NSObject>

- (void)requestRideView:(RequestRideView *)requestRideView didTapFareEstimate:(UIButton *)sender;
- (void)requestRideView:(RequestRideView *)requestRideView didTapCancel:(UIButton * _Nullable)sender;
- (void)requestRideView:(RequestRideView *)requestRideView didTapRequestRide:(UIButton *)sender;
@end

@interface RequestRideView : RACustomView

@property (weak, nonatomic) IBOutlet UILabel *lbPickupTimeMessage;


- (instancetype)initWithFlowController:(id <RequestRideViewNavigationProtocol>)flowController rideRequestManager:(id<FemaleDriverModeDataSource>)rideRequestManager andDelegate:(id<RequestRideViewDelegate>)delegate;
- (void)updateButtonCategoryTitle:(NSString *)categoryTitle;
- (void)updateRequestType:(NSNotification * _Nullable)notification;

@end
NS_ASSUME_NONNULL_END
