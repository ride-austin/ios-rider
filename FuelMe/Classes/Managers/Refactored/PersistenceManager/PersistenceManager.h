//
//  PersistenceManager.h
//  Ride
//
//  Created by Carlos Alcala on 11/30/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PersistenceManagerDefines.h"
#import "SplitResponse.h"

@class ConfigGlobal;

@interface PersistenceManager : NSObject

#pragma mark - Helpers

+ (BOOL)hasKeyDefined:(NSString*)key;
+ (void)storeObject:(id)object forRawKey:(NSString *)rawKey;
+ (void)archiveObject:(id)object forRawKey:(NSString *)rawKey;
+ (id)cachedObjectForKey:(NSString *)rawKey;
+ (NSString *)appendUserToKey:(NSString *)rawKey;

#pragma mark - Cached Config Global

+ (BOOL)hasConfigGlobal;
+ (void)saveConfigGlobal:(ConfigGlobal*)config;
+ (ConfigGlobal*)cachedConfigGlobal;

#pragma mark - Round Up Alert

+ (void)increaseCancelRoundUpPopupCount;
+ (BOOL)isCancelRoundUpPopupReachedLimit;
+ (void)resetCancelRoundUpPopupCount;

#pragma mark -  Split Fare

+ (void)cacheResponseForSplitInvitationWithResponse:(SplitResponse*)response ;
+ (BOOL)hasSplitFareResponseCached;
+ (SplitResponse*)getCachedResponse;
+ (BOOL)hasSplitResponseCachedWithSplitId:(NSString*)splitId;
+ (void)removeResponseFromArray:(SplitResponse*)response;
+ (void)clearCache;

#pragma mark - PreferredPaymentMethod

+ (NSString *)cachedPreferredPaymentMethod;
+ (void)savePreferredPaymentMethod:(NSString *)preferredPaymentMethodString;

#pragma mark - Branch CHannel
+ (void)saveBranchParams:(NSDictionary*)params;
+ (NSDictionary*) cachedBranchParams;
+ (void)clearBranchParams;

@end
