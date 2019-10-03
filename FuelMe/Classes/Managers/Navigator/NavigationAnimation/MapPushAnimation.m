//
//  MapPushAnimation.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "MapPushAnimation.h"

#define kAnimationDuration 1.5

@implementation MapPushAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat navBarMaxY = CGRectGetMaxY(toVC.navigationController.navigationBar.frame);
    
    CGRect finalFrame = [UIScreen mainScreen].bounds;
    finalFrame.origin.y = navBarMaxY;
    finalFrame.size.height -= navBarMaxY;
    toVC.view.frame = finalFrame;
    toVC.view.alpha = 0;
    [[transitionContext containerView] addSubview:toVC.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
