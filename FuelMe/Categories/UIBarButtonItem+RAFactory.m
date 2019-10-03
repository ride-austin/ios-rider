//
//  UIBarButtonItem+RAFactory.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/21/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "UIBarButtonItem+RAFactory.h"
#import "NSString+Utils.h"
#import "DNA.h"

@implementation UIBarButtonItem (RAFactory)

+ (instancetype)pinkWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self defaultWithTitle:title target:target action:action];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.femaleDriverPink} forState:UIControlStateNormal];
    return item;
}

+ (instancetype)defaultWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithTitle:title.localized.uppercaseString style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)blueImageName:(NSString *)imageName target:(id)target action:(SEL)action {
    return [self withImageName:imageName color:UIColor.azureBlue target:target action:action];
}

+ (instancetype)defaultImageName:(NSString *)imageName target:(id)target action:(SEL)action {
    return [self withImageName:imageName color:nil target:target action:action];
}

+ (instancetype)withImageName:(NSString *)imageName color:(UIColor *)color target:(id)target action:(SEL)action {
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    if (color) {
        item.tintColor = color;
    }
    return item;
}


@end
