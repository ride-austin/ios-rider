//
//  RACacheManager.h
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACacheManager : NSObject

+ (void)cacheObject:(id _Nullable)object forKey:( NSString* _Nonnull )key;
+ (id _Nullable) cachedObjectForKey:( NSString* _Nonnull )key;
+ (void)removeObjectForKey:( NSString* _Nonnull )key;

+ (void)setNilValueForKey:( NSString* _Nonnull )key;

+ (void)cacheBool:(BOOL)b forKey:( NSString* _Nonnull )key;
+ (BOOL) cachedBoolForKey:( NSString* _Nonnull )key;

+ (void)cacheInteger:(NSInteger)i forKey:( NSString* _Nonnull )key;
+ (NSInteger) cachedIntegerForKey:( NSString* _Nonnull )key;

+ (void)cacheDouble:(double)d forKey:( NSString* _Nonnull )key;
+ (double) cachedDoubleForKey:( NSString* _Nonnull )key;

+ (void)cacheURL:(NSURL * _Nullable)url forKey:( NSString* _Nonnull )key;
+ (NSURL * _Nullable) cachedURLForKey:( NSString* _Nonnull )key;


@end
