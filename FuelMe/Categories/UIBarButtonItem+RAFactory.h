//
//  UIBarButtonItem+RAFactory.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/21/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (RAFactory)

+ (instancetype _Nonnull)pinkWithTitle:(NSString * _Nonnull)title target:(id _Nullable)target action:(SEL _Nullable)action;
+ (instancetype _Nonnull)defaultWithTitle:(NSString * _Nonnull)title target:(id _Nullable)target action:(SEL _Nullable)action;
+ (instancetype _Nonnull)blueImageName:(NSString * _Nonnull)imageName target:(id _Nullable)target action:(SEL _Nullable)action;
+ (instancetype _Nonnull)defaultImageName:(NSString * _Nonnull)imageName target:(id _Nullable)target action:(SEL _Nullable)action;

@end
