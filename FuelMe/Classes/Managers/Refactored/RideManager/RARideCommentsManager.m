//
//  RARideCommentsManager.m
//  Ride
//
//  Created by Marcos Alba on 24/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARideCommentsManager.h"

#import "RACacheManager.h"

@interface RARideCommentsManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSString*> *commentsCache;

@end

@interface RARideCommentsManager (Internal)

- (NSString*)keyFromLocation:(CLLocationCoordinate2D)coordinate;

@end

@interface RARideCommentsManager (Cache)

- (void)saveCommentsCache;
- (NSMutableDictionary<NSString*,NSString*>*)getCommentsCache;

@end

@implementation RARideCommentsManager

+ (RARideCommentsManager *)sharedManager {
    static RARideCommentsManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RARideCommentsManager alloc] init];
    });
    return sharedInstance;

}

- (NSMutableDictionary<NSString*,NSString*>*)commentsCache {
    if (!_commentsCache) {
        _commentsCache = [self getCommentsCache];
        if (!_commentsCache) {
            _commentsCache = [[NSMutableDictionary alloc] init];
        }
    }
    
    return _commentsCache;
}

- (void)storeComment:(NSString *)comment forLocation:(CLLocationCoordinate2D)coordinate {
    NSString *key = [self keyFromLocation:coordinate];
    
    if (comment) {
        [self.commentsCache setObject:comment forKey:key];
    } else {
        [self.commentsCache removeObjectForKey:key];
    }
    
    [self saveCommentsCache];
}

- (NSString *)commentFromLocation:(CLLocationCoordinate2D)coordinate {
    NSString *key = [self keyFromLocation:coordinate];
    return [self.commentsCache objectForKey:key];
}

@end

@implementation RARideCommentsManager (Internal)

- (NSString *)keyFromLocation:(CLLocationCoordinate2D)coordinate {
    return [NSString stringWithFormat:@"<%f,%f>",coordinate.latitude,coordinate.longitude];
}

@end

static NSString *const kCommentsCacheKey = @"kCommentsCacheKey";

@implementation RARideCommentsManager (Cache)

- (void)saveCommentsCache {
    [RACacheManager cacheObject:self.commentsCache forKey:kCommentsCacheKey];
}

- (NSMutableDictionary<NSString*, NSString*>*)getCommentsCache {
    return [RACacheManager cachedObjectForKey:kCommentsCacheKey];
}

@end
