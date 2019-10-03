//
//  BottomDrawerView.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"
#import "RACategorySlider.h"
@class BottomDrawerView;
@protocol BottomDrawerViewDelegate <NSObject>
-(void)drawerView:(BottomDrawerView *)drawerView didSwipe:(UISwipeGestureRecognizerDirection)swipeDirection;
-(void)drawerView:(BottomDrawerView *)drawerView didTapGetRideEstimate:(UIButton *)sender;
-(void)drawerView:(BottomDrawerView *)drawerView didTapViewPricing:(UIButton *)sender;
-(void)drawerView:(BottomDrawerView *)drawerView didTapChevron:(UIButton *)sender;
-(void)drawerView:(BottomDrawerView *)drawerView didChangeSelectedCategory:(RACarCategoryDataModel *)selectedCategory;
@end
@interface BottomDrawerView : RACustomView
@property (weak, nonatomic) IBOutlet RACategorySlider *categorySlider;
@property (weak, nonatomic) IBOutlet UIImageView *ivChevron;

- (instancetype)initWithFlowController:(id)flowController andDelegate:(id<BottomDrawerViewDelegate>)delegate;
- (void)updateLabelsWithPickupETA:(NSInteger)pickupETA;


/**
 @return the constant needed to show only the slider
 */
- (CGFloat)constantWithVisibleSlider;
/**
 @return the constant needed to show the whole drawer
 */
- (CGFloat)constantWithVisibleDrawer;
@end

#import "RideConstants.h"
@interface BottomDrawerView (RALocationViewState)
-(void)updateVisibilityBasedOnState:(RALocationViewState)state;
@end
