//
//  LocationViewController.h
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressContainerAnimationProtocol.h"
#import "LFlowControllerProtocol.h"
#import "MessageFlowControllerProtocol.h"
#import "WomanOnlyViewController.h"
#import "RARideStatus.h"
@interface LocationViewController : BaseViewController <InsertingProtocol>

@property (nonatomic, weak, nullable) id<
DriverInfoViewNavigationProtocol,
LFlowControllerProtocol,
MessageFlowControllerProtocol,
RequestRideViewNavigationProtocol
> mainCoordinator;
@property (nonatomic, weak, nullable) id <SideMenuProtocol>sideMenuCoordinator;

@end

@interface LocationViewController (AddressContainerAnimationProtocol) <AddressContainerAnimationProtocol>

@end

@interface LocationViewController (WomanOnlyDelegate) <WomanOnlyViewDelegate>

@end

@interface LocationViewController (RideEnginePublic)

- (void)performRideStatusChangedTo:(RARideStatus)rideStatus;

@end
