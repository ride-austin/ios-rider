//
//  RANotificationSlide.h
//  Ride
//
//  Created by Robert on 5/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RANotificationSlideDelegate <NSObject>

- (void)didTapCloseNotificationSlide;

@end

@interface RANotificationSlide : UIView

@property (nonatomic, weak) id<RANotificationSlideDelegate> delegate;

+ (RANotificationSlide*)notificationWithMessage:(NSString*)message andParentView:(UIView*)view;

- (void)show;
- (void)close;

@end
