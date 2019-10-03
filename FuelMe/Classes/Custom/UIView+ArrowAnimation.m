//
//  UIView+ArrowAnimation.m
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIView+ArrowAnimation.h"
#import <objc/runtime.h>

@implementation UIView (ArrowAnimation)

- (void)setAnimationArrowIsShown:(BOOL)animationArrowIsShown {
    objc_setAssociatedObject(self, @selector(animationArrowIsShown), @(animationArrowIsShown), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)animationArrowIsShown {
    NSNumber *boolLiteral = (NSNumber*)objc_getAssociatedObject(self, @selector(animationArrowIsShown));
    return [boolLiteral boolValue];
}

- (void)showArrowAnimation {
    if (self.animationArrowIsShown) {
        return;
    }
    
    self.animationArrowIsShown = YES;
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = self.layer.bounds;
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    int numberOfElements = 3;
    
    CGFloat offsetX = 5.3;
    CGFloat bottomY = CGRectGetMaxY(replicatorLayer.bounds);
    CGFloat width = CGRectGetWidth(replicatorLayer.bounds);
    CGFloat midX = CGRectGetMidX(replicatorLayer.bounds);
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(offsetX, bottomY)];
    [arrowPath addLineToPoint:CGPointMake(midX, bottomY - 3.3)];
    [arrowPath addLineToPoint:CGPointMake(width - offsetX, bottomY)];
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.path = arrowPath.CGPath;
    arrowLayer.fillColor = [UIColor clearColor].CGColor;
    arrowLayer.frame = replicatorLayer.bounds;
    arrowLayer.strokeColor = [UIColor blackColor].CGColor;
    
    [replicatorLayer addSublayer:arrowLayer];
    replicatorLayer.instanceCount = numberOfElements;
    replicatorLayer.instanceDelay = 0.1;
    
    CATransform3D translation = CATransform3DMakeTranslation(0, -5, 0);
    CATransform3D scale = CATransform3DMakeScale(1.1, 1, 1);
    replicatorLayer.instanceTransform = CATransform3DConcat(translation, scale);
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0;
    alphaAnimation.toValue = @0.8;
    alphaAnimation.repeatCount = INFINITY;
    alphaAnimation.duration = 1;
    alphaAnimation.fillMode = kCAFillModeBackwards;
    alphaAnimation.removedOnCompletion = NO;
    [arrowLayer addAnimation:alphaAnimation forKey:@"alphaAnimation"];
    
    [self.layer addSublayer:replicatorLayer];
}

- (void)hideArrowAnimation {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.animationArrowIsShown = NO;
}

@end
