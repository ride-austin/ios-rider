//
//  UIView+ArrowAnimation.h
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ArrowAnimation)

@property (nonatomic, assign) BOOL animationArrowIsShown;

- (void)showArrowAnimation;
- (void)hideArrowAnimation;

@end
