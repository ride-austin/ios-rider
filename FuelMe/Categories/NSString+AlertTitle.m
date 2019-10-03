//
//  NSString+AlertTitle.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/4/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "NSString+AlertTitle.h"
#import "ConfigurationManager.h"
@implementation NSString (AlertTitle)

+ (NSString *)accessibleAlertTitleRideAustin {
    return [self accessibleAlertTitle:ConfigurationManager.appName];
}

+ (NSString *)accessibleAlertTitle:(NSString *)title {
    return UIAccessibilityIsVoiceOverRunning() ? nil : title;
}

@end
