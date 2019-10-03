//
//  RAPhotoPickerControllerManager.h
//  RideAustin
//
//  Created by Kitos on 3/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^RAPhotoPickerFinishedBlock)(UIImage *picture, NSError *error);
typedef void(^RAPhotoPickerCancelledBlock)(void);

@interface RAPhotoPickerControllerManager : NSObject

+ (RAPhotoPickerControllerManager*)pickerManager;

- (void)showPickerControllerFromViewController:(UIViewController *)viewController sender:(UIView *)sender allowEditing:(BOOL)allow finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler;
- (void)showPickerControllerFromViewController:(UIViewController*)viewController sender:(UIView *)sender allowEditing:(BOOL)allow finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler cancelledBlock:(RAPhotoPickerCancelledBlock)cancelledHandler;

@end
