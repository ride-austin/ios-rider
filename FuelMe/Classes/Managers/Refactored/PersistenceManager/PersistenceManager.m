//
//  PersistenceManager.m
//  Ride
//
//  Created by Carlos Alcala on 11/30/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PersistenceManager.h"
#import "ErrorReporter.h"
#import "RAMacros.h"
#import "RASessionManager.h"

#define defaults [NSUserDefaults standardUserDefaults]
#define userKey(x) [self appendUserToKey:x]
#define kRoundUpShowPopupLimit 3

@implementation PersistenceManager

#pragma mark - Helpers

+ (BOOL)hasKeyDefined:(NSString*)key{
    return [[[defaults dictionaryRepresentation] allKeys] containsObject:key];
}

+ (void)storeObject:(id)object forRawKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    if (key) {
        id existing = [defaults objectForKey:key];
        if (object) {
            if ([object isEqual:existing]) {
                return;
            }
            [defaults setObject:object forKey:key];
        } else {
            if (existing == nil) {
                return;
            }
            [defaults removeObjectForKey:key];
        }
        [defaults synchronize];
    } else {
        DBLog(@"Key is null - rawKey: %@",rawKey);
    }
}

+ (void)archiveObject:(id)object forRawKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    
    if (key) {
        [PersistenceManager archiveObject:object forFinalKey:key];
    } else{
        DBLog(@"Key is null - rawKey: %@",rawKey);
    }
}

+ (void)archiveObject:(id)object forFinalKey:(NSString *)finalKey {
    NSString *key = finalKey;
    id existing = [defaults objectForKey:key];
    if (object) {
        if ([object isEqual:existing]) {
            return;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        [defaults setObject:data   forKey:key];
    } else {
        if (existing == nil) {
            return;
        }
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
}

+ (id)cachedObjectForKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    if (key) {
        return [PersistenceManager cachedObjectForFinalKey:key];
    } else {
        DBLog(@"Key is null - rawKey: %@",rawKey);
    }
    
    return nil;
}

+ (id)cachedObjectForFinalKey:(NSString *)finalKey {
    NSString *key = finalKey;
    NSData *encodedObject = [defaults dataForKey:key];
    
    if (encodedObject) {
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        return object;
    } else {
        DBLog(@"Encoded Object is NULL");
        return nil;
    }
}

+(NSString *)appendUserToKey:(NSString *)someKey {
    NSString *userEmail = [[RASessionManager sharedManager] currentUser].email;
    if (userEmail && [userEmail isKindOfClass:[NSString class]]) {
        return [userEmail stringByAppendingString:someKey];
    } else {
        NSDictionary *userInfo   = @{@"key":someKey};
        [ErrorReporter recordErrorDomainName:WATCHCacheWithoutEmail withUserInfo:userInfo];
        return someKey;
    }
}

#pragma mark - Cached Config Global

+ (BOOL)hasConfigGlobal{
    return [self hasKeyDefined:kDefaultGlobalConfig];
}

+ (void)saveConfigGlobal:(ConfigGlobal*)config{
    [self archiveObject:config forFinalKey:kDefaultGlobalConfig];
}

+ (ConfigGlobal*)cachedConfigGlobal{
    return [self cachedObjectForFinalKey:kDefaultGlobalConfig];
}

#pragma mark - Round Up Alert

+ (void)increaseCancelRoundUpPopupCount{
    NSInteger count = [defaults integerForKey:kRoundUpCancelCount];
    count += 1;
    [defaults setInteger:count forKey:kRoundUpCancelCount];
    [defaults synchronize];
}

+ (BOOL)isCancelRoundUpPopupReachedLimit{
    NSInteger count = [defaults integerForKey:kRoundUpCancelCount];
    return count >= kRoundUpShowPopupLimit;
}

+ (void)resetCancelRoundUpPopupCount {
    [defaults setInteger:0 forKey:kRoundUpCancelCount];
}

#pragma mark - SplitFareResponse

+ (void)cacheResponseForSplitInvitationWithResponse:(SplitResponse*)response {
    NSMutableArray * responsesArray = [PersistenceManager getCachedSplitArray];
    if (!responsesArray) {
        responsesArray = [NSMutableArray new];
    }
    [responsesArray addObject:response];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:responsesArray] forKey:userKey(kSplitResponses)];
    [defaults synchronize];
}

+ (NSMutableArray*)getCachedSplitArray {
    NSData *dataSplitResponseArray = [defaults objectForKey:userKey(kSplitResponses)];
    NSMutableArray * responsesArray;
    if (dataSplitResponseArray != nil) {
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataSplitResponseArray];
        if (oldSavedArray != nil) {
            responsesArray = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        } else {
            responsesArray = [[NSMutableArray alloc] init];
        }
    }
    return  responsesArray;
}

+ (BOOL)hasSplitFareResponseCached {
    NSMutableArray *splitResponseArray = [PersistenceManager getCachedSplitArray];
    return splitResponseArray.count > 0;
}

+ (SplitResponse*)getCachedResponse {
    NSMutableArray *splitResponseArray = [PersistenceManager getCachedSplitArray];
    SplitResponse *response = [splitResponseArray lastObject];
    return response;
}

+ (BOOL)hasSplitResponseCachedWithSplitId:(NSString*)splitId {
    NSMutableArray *responsesArray = [PersistenceManager getCachedSplitArray];
    for (SplitResponse *response in responsesArray) {
        if ([response.splitID isEqualToString:splitId]) {
            return YES;
        }
    }
    return NO;
}

+ (void)removeResponseFromArray:(SplitResponse*)response{
    NSMutableArray * splitResponseArray = [PersistenceManager getCachedSplitArray];
    [splitResponseArray removeObject:response];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:splitResponseArray] forKey:userKey(kSplitResponses)];
    [defaults synchronize];
}

+ (void)clearCache{
    [defaults removeObjectForKey:userKey(kSplitResponses)];
    [defaults synchronize];
}

#pragma mark - PreferredPaymentMethod

+ (NSString *)cachedPreferredPaymentMethod {
    return [defaults stringForKey:kPreferredPaymentMethod];
}

+ (void)savePreferredPaymentMethod:(NSString *)preferredPaymentMethodString {
    [defaults setObject:preferredPaymentMethodString forKey:kPreferredPaymentMethod];
    [defaults synchronize];
}

#pragma mark - Branch CHannel

+ (void)saveBranchParams:(NSDictionary*)params {
    [defaults setObject:params forKey:kBranchParams];
    [defaults synchronize];
}

+ (NSDictionary*) cachedBranchParams {
     return [defaults objectForKey:kBranchParams];
}

+ (void)clearBranchParams {
    [defaults removeObjectForKey:kBranchParams];
    [defaults synchronize];
}

@end
