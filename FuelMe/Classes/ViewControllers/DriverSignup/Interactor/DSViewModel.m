//
//  DSViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"

@implementation DSViewModel

- (instancetype)initWithConfig:(ConfigRegistration *)config andCache:(SDImageCache *)cache {
    if (self = [super init]) {
        _cache = cache;
        _config = config;
    }
    return self;
}

- (void)saveImage:(UIImage *)image forKey:(NSString *)key {
    NSParameterAssert(self.cache != nil);
    __weak __typeof__(self) weakself = self;
    if (image) {
        [self.cache storeImage:image forKey:key completion:^{
            weakself.isProvided = YES;
        }];
    } else {
        [self.cache removeImageForKey:key withCompletion:^{
            weakself.isProvided = NO;
        }];
    }
}

- (NSString *)appName {
    return self.config.city.appName;
}

@end
