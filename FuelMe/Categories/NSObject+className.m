//
//  NSObject+className.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSObject+className.h"

@implementation NSObject (className)

+ (NSString *)className {
    return NSStringFromClass([self class]);
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (NSString *)navigationBarName {
    return [NSString stringWithFormat:@"%@NavigationBar", self.className];
}

@end
