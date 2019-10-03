//
//  PickerAddressPushAnimation.m
//  Ride
//
//  Created by Roberto Abreu on 9/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressPushAnimation.h"
#import "AddressContainerAnimationProtocol.h"
#import "NSNotificationCenterConstants.h"
#import "PickerAddressViewController.h"

#define kExpandFieldsMargin -5
#define kFieldTopConstraint -50

@implementation PickerAddressPushAnimation

#pragma mark - UIViewControllerAnimatedTransitioning Protocol

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPickerAddressWillAppear object:nil];
    
    //Initialize properties
    UIView *containerView = [transitionContext containerView];
    UIView *pickerAddressView = [transitionContext viewForKey:UITransitionContextToViewKey];
    PickerAddressViewController *pickerAddressViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<AddressContainerAnimationProtocol> *locationViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (![pickerAddressViewController isKindOfClass:[PickerAddressViewController class]] || ![locationViewController isKindOfClass:[locationViewController class]]) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    //Reorder SubViews
    RAPickerAddressFieldType pickerAddressFieldType = pickerAddressViewController.pickerAddressFieldType;
    if (pickerAddressFieldType == RAPickerAddressPickupFieldType) {
        [locationViewController.viewAddressFields bringSubviewToFront:locationViewController.viewPickupField];
    } else if (pickerAddressFieldType == RAPickerAddressDestinationFieldType) {
        [locationViewController.viewAddressFields bringSubviewToFront:locationViewController.viewDestinationField];
    }
    
    pickerAddressView.alpha = 0;
    pickerAddressView.frame = [transitionContext finalFrameForViewController:pickerAddressViewController];
    [containerView addSubview:pickerAddressView];
    
    //Animate
    [locationViewController setDestinationFieldTopConstraint:kFieldTopConstraint];
    [locationViewController setCommentFieldTopConstraint:kFieldTopConstraint];
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [locationViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [locationViewController setAddressContainerTopConstraint:kExpandFieldsMargin];
        [locationViewController setAddressContainerLeadingTrailingConstraint:kExpandFieldsMargin];
        
        [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [locationViewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                pickerAddressView.alpha = 1;
                [pickerAddressViewController.tblPlaces layoutIfNeeded];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }];
        
    }];
}

@end
