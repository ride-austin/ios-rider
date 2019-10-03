//
//  RACacheManager.m
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACacheManager.h"

#import "ErrorReporter.h"
#import "RAMacros.h"
#import "RASessionManager.h"

#define defaults [NSUserDefaults standardUserDefaults]

@interface RACacheManager ()

@end

@interface RACacheManager (Private)

+ (NSString* _Nonnull) userKeyFromKey:(NSString* _Nonnull)key;

@end

@implementation RACacheManager

+ (void)cacheObject:(id)object forKey:(NSString *)key {
    id obj = object;
    if (object) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        if (data) {
            obj = data;
        }
    }
    NSString *k = [self userKeyFromKey:key];
    if ([k isEqualToString:key]) {
        return;
    }
    [defaults setObject:obj forKey:k];
    [defaults synchronize];
}

+ (id)cachedObjectForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    if ([k isEqualToString:key]) {
        return nil;
    }
    id obj = [defaults objectForKey:k];
    if ([obj isKindOfClass:[NSData class]]) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData*)obj];
    }
    
    return obj;
}

+ (void)removeObjectForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults removeObjectForKey:k];
    [defaults synchronize];
}

+ (void)setNilValueForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults setNilValueForKey:k];
    [defaults synchronize];
}

+ (void)cacheBool:(BOOL)b forKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults setBool:b forKey:k];
    [defaults synchronize];
}

+ (BOOL)cachedBoolForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    return [defaults boolForKey:k];
}

+ (void)cacheInteger:(NSInteger)i forKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults setInteger:i forKey:k];
    [defaults synchronize];
}

+ (NSInteger)cachedIntegerForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    return [defaults integerForKey:k];
}

+ (void)cacheDouble:(double)d forKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults setDouble:d forKey:k];
    [defaults synchronize];
}

+ (double)cachedDoubleForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    return [defaults doubleForKey:k];
}

+ (void)cacheURL:(NSURL *)url forKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    [defaults setURL:url forKey:k];
    [defaults synchronize];
}

+ (NSURL *)cachedURLForKey:(NSString *)key {
    NSString *k = [self userKeyFromKey:key];
    return [defaults URLForKey:k];
}

@end

#pragma mark - Private

@implementation RACacheManager (Private)

+ (NSString *)userKeyFromKey:(NSString *)key {
    NSString *userEmail = [[RASessionManager sharedManager] currentUser].email;
    BOOL hasUserEmail = !IS_EMPTY(userEmail);
    if (hasUserEmail) {
        return [userEmail stringByAppendingString:key];
    } else {
        NSDictionary *userInfo   = @{@"key":key};
        [ErrorReporter recordErrorDomainName:WATCHCacheWithoutEmail withUserInfo:userInfo];
        //NSAssert(hasUserEmail, @"tried to access RACacheManager key %@ without user, please fix", key);
        return key;
    }
}

@end
