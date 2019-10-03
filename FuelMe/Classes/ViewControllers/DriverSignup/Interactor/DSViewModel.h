//
//  DSViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigRegistration.h"
#import "DSCacheConstants.h"

#import <SDWebImage/SDImageCache.h>

@interface DSViewModel : NSObject

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isMandatory;
@property (nonatomic) BOOL isProvided;
@property (nonatomic) BOOL isSubmitted;
@property (nonatomic, readonly, weak) SDImageCache *cache;
@property (nonatomic, readonly, weak) ConfigRegistration *config;

- (instancetype)initWithConfig:(ConfigRegistration *)config andCache:(SDImageCache *)cache;
- (void)saveImage:(UIImage *)image forKey:(NSString *)key;

- (NSString *)appName;

@end
