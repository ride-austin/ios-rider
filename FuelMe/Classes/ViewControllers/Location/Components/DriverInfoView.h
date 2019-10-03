//
//  DriverInfoView.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/5/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"
#import "LFlowControllerProtocol.h"
typedef NS_ENUM(NSUInteger, DriverInfoViewState) {
    DriverInfoViewStateCollapsed = 0,
    DriverInfoViewStateExpanded = 1
};

@class RARideDataModel;
@class DriverInfoView;
@protocol DriverInfoViewDelegate <NSObject>
@required
- (void)driverInfoView:(DriverInfoView *)driverInfoView didTapCancelWithCompletion:(void(^)(void))completion;
- (void)driverInfoView:(DriverInfoView *)driverInfoView didTapFareEstimate:(UIButton *)sender;
- (void)driverInfoView:(DriverInfoView *)driverInfoView willResizeWithVisibleHeight:(CGFloat)visibleHeight;
@end

@interface DriverInfoView : RACustomView

@property (nonatomic, readonly) DriverInfoViewState state;

- (instancetype)initWithFrame:(CGRect)frame flowController:(id<DriverInfoViewNavigationProtocol>)flowController andDelegate:(id<DriverInfoViewDelegate>)delegate;

- (void)collapse;
- (void)updateBasedOnRide:(RARideDataModel *)ride;
//height is 271 when deaf, 228 when not deaf
- (CGFloat)visibleHeightCollapsed;

@end
