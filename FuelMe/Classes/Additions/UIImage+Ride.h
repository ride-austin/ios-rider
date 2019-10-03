//
//  UIImage+Ride.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/10/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ride)

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
/**
 *  @brief resize the image to fit 90% of maxArea
 */
+ (UIImage*)imageWithImage:(UIImage*)image scaledToMaxArea:(CGFloat)absoluteMaxArea;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize andMaxArea:(CGFloat)maxArea;

- (BOOL)imageValidSizeForMinArea:(CGFloat)minArea;
- (NSData *)compressToMaxSize:(CGFloat)maxSize;

@end
