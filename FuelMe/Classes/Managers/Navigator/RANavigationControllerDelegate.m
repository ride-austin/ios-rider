//
//  RANavigationControllerDelegate.m
//  Ride
//
//  Created by Roberto Abreu on 9/28/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RANavigationControllerDelegate.h"

#import "FakeLaunchViewController.h"
#import "LocationViewController.h"
#import "MapPushAnimation.h"
#import "PickerAddressPopAnimation.h"
#import "PickerAddressPushAnimation.h"
#import "PickerAddressViewController.h"
#import "SelectPlaceMapViewController.h"
#import "SplashPushAnimation.h"
#import "SplashViewController.h"

@implementation RANavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    BOOL shouldAnimateFromFakeLaunch = operation == UINavigationControllerOperationPush && [fromVC isKindOfClass:[FakeLaunchViewController class]];
    if (shouldAnimateFromFakeLaunch) {
        return [self animationToVC:toVC];
    }
    
    if ([fromVC isKindOfClass:[LocationViewController class]] && [toVC isKindOfClass:[PickerAddressViewController class]]) {
        return [PickerAddressPushAnimation new];
    }
    
    if (([fromVC isKindOfClass:[PickerAddressViewController class]] || [fromVC isKindOfClass:[SelectPlaceMapViewController class]]) && [toVC isKindOfClass:[LocationViewController class]]) {
        return [PickerAddressPopAnimation new];
    }
    
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)animationToVC:(UIViewController *)toVC {
    if ([toVC isKindOfClass:[LocationViewController class]]) {
        return [MapPushAnimation new];
    } else if ([toVC isKindOfClass:[SplashViewController class]]) {
        return [SplashPushAnimation new];
    } else {
        return nil;
    }
}

@end
