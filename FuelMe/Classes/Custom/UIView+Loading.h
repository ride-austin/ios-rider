//
//  UIView+Loading.h
//  Ride
//
//  Created by Roberto Abreu on 30/8/16.
//  Copyright (c) 2016 FuelMe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CarAnimationState) {
    CarAnimationUnkwnon,
    CarAnimationLoaded,
    CarAnimationLoading
};

@interface UIView (Loading)

@property (assign, nonatomic) CarAnimationState carAnimationState;

- (void)showLoading;
- (void)showLoaded;
- (void)cleanLayers;

@end
