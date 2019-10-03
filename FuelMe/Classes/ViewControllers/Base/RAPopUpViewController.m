//
//  RAPopUpViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPopUpViewController.h"

@interface RAPopUpViewController ()

@property (nonatomic) UIView *vBackground;

@end

@implementation RAPopUpViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldDismissOnBackgroundTouch = YES;
        _dismissType = RAPopupDismissTypeBounceOut;
        _showType    = RAPopupShowTypeBounceIn;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-  (UIView *)vBackground {
    if (!_vBackground) {
        _vBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _vBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        if (self.shouldDismissOnBackgroundTouch) {
            [_vBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        }
    }
    return _vBackground;
}

- (void)showInParent:(UIViewController *)parent {
    [parent.navigationController addChildViewController:self];
    [self.vBackground addSubview:self.view];
    self.view.center = self.vBackground.center;
    
    void(^completion)(BOOL finished) = ^(BOOL finished) {
        [self didMoveToParentViewController:parent.navigationController];
    };
    
    switch (self.showType) {
        case RAPopupShowTypeBounceIn: {
            self.vBackground.alpha = 0;
            self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            [parent.navigationController.view addSubview:self.vBackground];
            [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:15.0 options:0 animations:^{
                self.vBackground.alpha = 1.0;
                self.view.transform = CGAffineTransformIdentity;
                self.view.center = self.vBackground.center;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.view.center = self.vBackground.center;
                } completion:completion];
            }];
            break;
        }
        default: {
            self.vBackground.alpha = 1.0;
            self.view.transform = CGAffineTransformIdentity;
            completion(YES);
            break;
        }
    }
}

- (void)dismiss {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    
    void(^completion)(BOOL finished) = ^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.vBackground removeFromSuperview];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
    };
    
    NSTimeInterval bounce1Duration = 0.13;
    NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
    
    switch (self.dismissType) {
        case RAPopupDismissTypeBounceOut: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounce2Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    self.vBackground.alpha = 0;
                    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:completion];
            }];
            break;
        }
            
        default: {
            self.vBackground.alpha = 0;
            completion(YES);
            break;
        }
    }
}

@end
