//
//  UIView+Loading.m
//
//  Created by Roberto Abreu on 30/8/16.
//  Copyright (c) 2016 FuelMe, Inc. All rights reserved.
//

#import "UIView+Loading.h"

#import <objc/runtime.h>

static char* ANIMATION_STATE_KEY = "StateKey";

@implementation UIView (Loading)

- (void)setCarAnimationState:(CarAnimationState)carAnimationState {
    objc_setAssociatedObject(self, ANIMATION_STATE_KEY, @(carAnimationState), OBJC_ASSOCIATION_ASSIGN);
}

- (CarAnimationState)carAnimationState {
    return [objc_getAssociatedObject(self, ANIMATION_STATE_KEY) integerValue] ?: CarAnimationUnkwnon;
}

#pragma mark - Methods

- (void)showLoading {
    [self cleanLayers];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    circleLayer.lineWidth = 1.0;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:circleLayer];
    
    //Animate Circle Layer
    double totalDuration = 1.0;
    double firstDuration = 2.0 * totalDuration / 3.0;
    double secondDuration = totalDuration / 3.0;
    
    CABasicAnimation *headAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    headAnimation.duration = firstDuration;
    headAnimation.fromValue = @0.0;
    headAnimation.toValue = @0.25;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    tailAnimation.duration = firstDuration;
    tailAnimation.fromValue = @0.0;
    tailAnimation.toValue = @0.7;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    endHeadAnimation.beginTime = firstDuration;
    endHeadAnimation.duration = secondDuration;
    endHeadAnimation.fromValue = @0.25;
    endHeadAnimation.toValue = @1.0;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endTailAnimation.beginTime = firstDuration;
    endTailAnimation.duration = secondDuration;
    endTailAnimation.fromValue = @0.7;
    endTailAnimation.toValue = @1.0;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.duration = totalDuration;
    alphaAnimation.toValue = @0.3;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.duration = firstDuration + secondDuration;
    animations.repeatCount = INFINITY;
    animations.animations = @[alphaAnimation,headAnimation, tailAnimation, endHeadAnimation, endTailAnimation];
    
    [circleLayer addAnimation:animations forKey:@"groupAnimation"];
    [self setCarAnimationState:CarAnimationLoading];
}

- (void)showLoaded {

    [self cleanLayers];
    [self.layer setValue:@YES forKey:@"showed"];
    
    //Outer Path
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    circleLayer.lineWidth = 1.0;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:circleLayer];
    
    //Dot Body
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, -0.5, 4, 4)];
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    dotLayer.path = dotPath.CGPath;
    dotLayer.fillColor = [UIColor whiteColor].CGColor;
    
    //Tail and Head Part
    UIBezierPath *bodyPath = [UIBezierPath bezierPathWithRect:CGRectMake(-2, 0, 8, 3)];
    CAShapeLayer *bodyLayer = [CAShapeLayer layer];
    bodyLayer.path = bodyPath.CGPath;
    
    bodyLayer.fillColor = [UIColor blackColor].CGColor;
    
    //Car Container
    CALayer *carLayer = [CALayer layer];
    [carLayer addSublayer:bodyLayer];
    [carLayer addSublayer:dotLayer];
    [self.layer addSublayer:carLayer];
    
    //Animate Car around circle path
    [CATransaction setDisableActions:YES];
    UIBezierPath *circleAnimationPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, -1, -1)];
    CAKeyframeAnimation *dotAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    dotAnimation.path = circleAnimationPath.CGPath;
    dotAnimation.repeatCount = INFINITY;
    dotAnimation.duration = 15.0;
    dotAnimation.fillMode = kCAFillModeBoth;
    dotAnimation.calculationMode = kCAAnimationPaced;
    dotAnimation.rotationMode = kCAAnimationRotateAuto;
    [carLayer addAnimation:dotAnimation forKey:@"carAnimation"];
    
    [self setCarAnimationState:CarAnimationLoaded];
}

- (void)cleanLayers {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setCarAnimationState:CarAnimationUnkwnon];
}

@end
