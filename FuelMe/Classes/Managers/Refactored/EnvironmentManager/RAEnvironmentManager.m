//
//  RAEnvironmentManager.m
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAEnvironmentManager.h"

#import "AppConfig.h"

static NSString * const kEnvironmentKey      = @"kEnvironmentKey";
static NSString * const kCustomServerURLKey  = @"kCustomServerURLKey";

@implementation RAEnvironmentManager

+ (RAEnvironmentManager*)sharedManager {
    static RAEnvironmentManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RAEnvironmentManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
#ifndef TEST
        self.environment = RAProdEnvironment;
#endif
        
#ifdef TEST
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:kEnvironmentKey]) {
            self.environment = (RAEnvironment)[userDefaults integerForKey:kEnvironmentKey];
        } else {
            self.environment = RAQAEnvironment;
        }
#endif
    }
    return self;
}

- (BOOL)isTestMode {
    BOOL testMode = NO;
#ifdef DEV
    testMode = YES;
#endif
    
#ifdef QA
    testMode = YES;
#endif
    return testMode;
}

- (void)setEnvironment:(RAEnvironment)environment {
    _environment = environment;
    switch (self.environment) {
        case RAStageEnvironment:
            self.serverUrl = [AppConfig stageServerURL];
            break;
        case RAFeatureEnvironment:
            self.serverUrl = [AppConfig featureServerURL];
            break;
        case RADevEnvironment:
            self.serverUrl = [AppConfig devServerURL];
            break;
        case RAQAEnvironment:
            self.serverUrl = [AppConfig qaServerURL];
            break;
        case RAProdEnvironment:
            self.serverUrl = [AppConfig productionServerURL];
            break;
        case RACustomEnvironment:{
            NSString *sURL = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomServerURLKey];
            self.serverUrl = sURL ? sURL : [AppConfig stageServerURL];
        }
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.environment forKey:kEnvironmentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)version {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    
    if ([self isTestMode]) {
        NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
        version = [version stringByAppendingFormat:@" (%@) - %@", build, [self environmentString]];
    }
    
    return version;
}

+ (NSString *)userAgentVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return [version stringByAppendingFormat:@" (%@)", build];
}

- (NSString *)completeVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return [version stringByAppendingFormat:@" (%@)", build];
}

- (NSString *)environmentString {
    NSString *env = @"Unknown";
    switch (self.environment) {
        case RAStageEnvironment:
            env = @"Stage";
            break;
        case RAFeatureEnvironment:
            env = @"Feature";
            break;
        case RADevEnvironment:
            env = @"DEV";
            break;
        case RAQAEnvironment:
            env = @"QA";
            break;
        case RACustomEnvironment:
            env = @"Custom";
            break;
        case RAProdEnvironment:
            env = @"PROD";
            break;
        default:
            break;
    }
    
    return env;
}

- (BOOL)isTestServer {
    return self.environment == RAQAEnvironment;
}

- (BOOL)isStageServer {
    return self.environment == RAStageEnvironment;
}

- (BOOL)isCustomServer {
    return self.environment == RACustomEnvironment;
}

- (BOOL)isProdServer {
    return self.environment == RAProdEnvironment;
}

- (NSString *)environmentQueryForRealTimeTracking {
    NSString *env = @"";
    if (self.environment != RAProdEnvironment) {
        NSString *serverURL = [[RAEnvironmentManager sharedManager] serverUrl];
        env = [serverURL stringByReplacingOccurrencesOfString:@"http://api-" withString:@""];
        env = [env stringByReplacingOccurrencesOfString:@"https://api-" withString:@""];
        env = [env stringByReplacingOccurrencesOfString:@".rideaustin.com/rest" withString:@""];
        env = [NSString stringWithFormat:@"&env=%@",env];
    }
    return env;
}

@end

@implementation RAEnvironmentManager (Customization)

- (void)setCustomServerURL:(NSString *)serverURL {
    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:kCustomServerURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.environment = RACustomEnvironment;
}

@end
