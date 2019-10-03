//
//  RAEnvironmentManager.h
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAEnvironmentDefines.h"

@interface RAEnvironmentManager : NSObject

@property (nonatomic, readonly, getter=isTestMode) BOOL testMode;
@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *completeVersion;
@property (nonatomic, readonly) NSString *environmentString;
@property (nonatomic) RAEnvironment environment;

+ (RAEnvironmentManager*)sharedManager;

- (BOOL)isTestServer;
- (BOOL)isStageServer;
- (BOOL)isCustomServer;
- (BOOL)isProdServer;
+ (NSString *)userAgentVersion;
- (NSString * _Nonnull)environmentQueryForRealTimeTracking;

@end

@interface RAEnvironmentManager (Customization)

- (void)setCustomServerURL:(NSString*)serverURL;

@end
