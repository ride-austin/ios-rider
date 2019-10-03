//
//  UIColor+raColors.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIColor+raColors.h"
#import "UIColor+HexUtils.h"

@implementation UIColor (raColors)

+ (UIColor *)azureBlue {
    return [UIColor colorWithRed:2/255.0 green:167/255.0 blue:249/255.0 alpha:1];
}

+ (UIColor *)barButtonGray {
    return [UIColor colorWithRed:44/255.0 green:50/255.0 blue:60/255.0 alpha:1];
}

+ (UIColor *)femaleDriverPink {
    return [UIColor colorWithRed:249/255.0 green:22/255.0 blue:135/255.0 alpha:1];
}

+ (UIColor *)routeBlue {
    return [UIColor colorWithRed:0. green:174/255. blue:239/255. alpha:0.6];
}

+ (UIColor *)warningYellow {
    return [UIColor colorWithRed:1 green:142/255.0 blue:30/255.0 alpha:1.0];
}

+ (UIColor *)bombayGray {
    return [UIColor colorWithRed:177/255.0 green:180/255.0 blue:187/255.0 alpha:1.0];
}

+ (UIColor *)charcoalGrey {
    return [UIColor colorWithRed:60/255.0 green:67/255.0 blue:80/255.0 alpha:1.0];
}

+ (UIColor *)grayBackground {
    return [UIColor colorWithRed:242/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
}

+ (UIColor *)textFieldBorder {
    return [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0];
}

+ (UIColor *)placeholderColor {
    return [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0];
}

+ (UIColor *)grayIconTint {
    return [UIColor colorWithRed:159/255.0 green:161/255.0 blue:166/255.0 alpha:1.0];
}

+ (UIColor *)darkTitle {
    return [UIColor colorWithRed:7/255.0 green:13/255.0 blue:22/255.0 alpha:1.0];
}

+ (UIColor *)disabledButton {
    return [UIColor colorWithHex: @"B1B4BB"];
}
@end
