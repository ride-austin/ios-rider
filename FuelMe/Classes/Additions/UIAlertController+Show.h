//
//  UIAlertController+Show.h
//  RideDriver
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Show)

@property (nonatomic, strong) UIWindow *alertWindow;

- (void)show;
- (void)show:(BOOL)animated;

@end
