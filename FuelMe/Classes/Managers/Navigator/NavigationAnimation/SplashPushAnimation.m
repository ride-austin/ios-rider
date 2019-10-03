//
//  SplashPushAnimation.m
//  Ride
//
//  Created by Theodore Gonzalez on 7/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SplashPushAnimation.h"

#define kAnimationDuration 0.5

@implementation SplashPushAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];;
    toVC.view.alpha = 0;
    toVC.view.transform = CGAffineTransformMakeScale(2, 2);
    [[transitionContext containerView] addSubview:toVC.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toVC.view.alpha = 1;
        toVC.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}

@end
