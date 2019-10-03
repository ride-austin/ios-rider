//
//  UIImage+Utils.h
//  RideAustin
//
//  Created by Kitos on 27/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage*)scaledImageTo:(CGFloat)scale;
- (UIImage*)scaledToSize:(CGSize)newSize;
- (UIImage*)scaledToMaxArea:(CGFloat)absoluteMaxArea;
- (UIImage*)scaledToSize:(CGSize)newSize andMaxArea:(CGFloat)absoluteMaxArea;
- (UIImage*)combineWithImage:(UIImage *)image;
@end
