//
//  CALayer+UIColor.h
//  Ride
//
//  Created by Tyson Bunch on 5/13/16.
//  Copyright © 2016 FuelMe, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (UIColor)

@property (assign, nonatomic) UIColor *borderUIColor;
@property (assign, nonatomic) UIColor *shadowUIColor;

@end
