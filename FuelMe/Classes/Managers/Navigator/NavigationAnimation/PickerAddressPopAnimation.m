//
//  PickerAddressPopAnimation.m
//  Ride
//
//  Created by Roberto Abreu on 9/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressPopAnimation.h"
#import "AddressContainerAnimationProtocol.h"
#import "NSNotificationCenterConstants.h"
#import "PickerAddressViewController.h"

#define kCollapsedFieldsMargin 11
#define kFieldTopConstraint -9

@implementation PickerAddressPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    //Initialize properties
    UIView *containerView = [transitionContext containerView];
    UIView *locationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIViewController<AddressContainerAnimationProtocol> *locationViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    locationView.frame = [transitionContext finalFrameForViewController:locationViewController];
    [containerView insertSubview:locationView belowSubview:fromView];
    
    //Animate
    [UIView animateWithDuration:0.2 animations:^{
        fromView.alpha = 0;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        [locationViewController  setAddressContainerTopConstraint:kCollapsedFieldsMargin];
        [locationViewController  setAddressContainerLeadingTrailingConstraint:kCollapsedFieldsMargin];
        
        [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [locationViewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [locationViewController setDestinationFieldTopConstraint:kFieldTopConstraint];
            [locationViewController setCommentFieldTopConstraint:kFieldTopConstraint];
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [locationViewController.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPickerAddressDidDisappear object:nil];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }];
    }];
    
}

@end
