//
//  UIAlertController+Window.h
//  FFM
//
//  Created by Eric Larson on 6/17/15.
//  Copyright (c) 2015 ForeFlight, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Window)

@property (nonatomic, readonly) UIWindow *windowAlert;

- (void)show;
- (void)showOnTop;
- (void)show:(BOOL)animated onTop:(BOOL)onTop;
- (BOOL)isShowing;

@end
