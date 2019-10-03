//
//  TestConfiguration.m
//  RideAustinTest-Automation
//
//  Created by Roberto Abreu on 11/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TestConfiguration.h"
#import "RAMacros.h"

static NSString *kParentsKey = @"parents";    // Array<String>. Parent configuration names
static NSString *kShouldClearCacheKey = @"shouldClearCache";
static NSString *kUseStubsKey = @"useStubs";    // BOOL
static NSString *kRegistrationStickerEnabled = @"registrationStickerEnabled";
static NSString *kUseRealAuthKey = @"useRealAuth";    // BOOL
static NSString *kLogoutDelayKey = @"logoutDelay";    // Double
static NSString *knetworkUnreachableDelayKey = @"networkUnreachableDelay";    // Double
static NSString *kCityKey = @"city";    // Integer. See CityType
static NSString *kRideConfigurationKey = @"rideConfiguration";  // Dictionary
static NSString *kRideResourcesKey = @"resources"; // Array<String>
static NSString *kRideInitialTimeKey = @"initialTime"; // Integer. starting ride at time.
static NSString *kRideStatusBeforeCancelled = @"statusBeforeCancelled"; // Integer. See MockRideStatus
static NSString *kRideWhoCancells = @"whoCancels"; // Integer. See MockRideStatus
static NSString *kRideInjections = @"injections"; // Array<Dictionary>
static NSString *kRideInjectionType = @"injectionType"; //NSUInteger. See DBRideInjectionType
static NSString *kRideInjectionAfterStatus = @"injectionAfterStatus"; // Integer. See MockRideStatus. It only has sense for MockRideStatusDriverAssigned = 2, MockRideStatusDriverReached = 3, MockRideStatusActive = 4
static NSString *kRideInjectionDelay = @"injectionDelay"; // NSUInteger (delay after status)
static NSString *kRideInjectionTimeout = @"injectionTimeout"; // NSInteger (timeout for injection. Currently used only for no network simulation). A value <= 0 means to no timeout.
static NSString *kRideInjectionJSONFile = @"injectionJSON"; // String (File name in which is JSON dictionary)

@interface TestConfiguration()

@property (nonatomic) NSDictionary *configurationsDict;

@end

@implementation TestConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.shouldClearCache = YES;
        self.useStubs = YES;
        self.registrationStickerEnabled = NO;
        self.useRealAuthentication = NO;
        self.logoutDelay = 0;
        self.networkUnreachableDelay = -1;
        self.city = Austin;
        self.rideConfiguration = [DBRideStubConfiguration new];
    }
    return self;
}

- (void)loadConfigurationFromFile:(NSString *)name {
    NSString *stubConfigurationsPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    self.configurationsDict = [NSDictionary dictionaryWithContentsOfFile:stubConfigurationsPath];
    NSAssert(self.configurationsDict, @"Configurations file not found - 'StubConfigurations.plist'");
    [self loadConfiguration];
}

- (void)loadConfiguration {
    if(self.configurationsDict){
        NSArray<NSString*>* arguments = [NSProcessInfo processInfo].arguments;
        NSUInteger argIndex = [arguments indexOfObject:@"--StubConfiguration"];
        NSString *stubConfigurationValue = nil;
        if (argIndex != NSNotFound && arguments.count > (argIndex+1)) {
            stubConfigurationValue = arguments[argIndex+1];
        }
        
        if (!stubConfigurationValue) {
            stubConfigurationValue = @"Default";
            DBLog(@"<Test configuration: No configuration specified --> using Default>");
        }
        
        NSDictionary *configuration = [self configurationWithName:stubConfigurationValue];
        if(configuration){
            NSArray<NSString*> *parentConfigs = [self parentsRecursiveTreeFromConfiguration:configuration];
            if (parentConfigs) {
                for (NSString *parentConfig in parentConfigs) {
                    NSDictionary *config = [self configurationWithName:parentConfig];
                    [self loadConfiguration:config];
                }
            }
            [self loadConfiguration:configuration];
        } else {
            DBLog(@"<Test configuration: The configuration specified (%@) cannot be found in plist>",configuration);
        }
    }
}

- (void)loadConfiguration:(NSDictionary *)configuration {
    NSNumber *shouldClearCache = configuration[kShouldClearCacheKey];
    if (shouldClearCache) {
        self.shouldClearCache = [shouldClearCache boolValue];
    }
    
    NSNumber *useStubs = configuration[kUseStubsKey];
    if (useStubs) {
        self.useStubs = [useStubs boolValue];
    }
    
    NSNumber *registrationStickerEnabled = configuration[kRegistrationStickerEnabled];
    if (registrationStickerEnabled) {
        self.registrationStickerEnabled = [registrationStickerEnabled boolValue];
    }
    
    NSNumber *useRealAuth = configuration[kUseRealAuthKey];
    if (useRealAuth) {
        self.useRealAuthentication =  [useRealAuth boolValue];
    }
    
    NSNumber *logoutDelay = configuration[kLogoutDelayKey];
    if (logoutDelay) {
        self.logoutDelay = logoutDelay.doubleValue;
    }
    
    NSNumber *netUnreachableDelay = configuration[knetworkUnreachableDelayKey];
    if (netUnreachableDelay) {
        self.networkUnreachableDelay = netUnreachableDelay.doubleValue;
    }
    
    NSNumber *city = configuration[kCityKey];
    if (city) {
        self.city = (CityType)city.integerValue;
    }
    
    NSDictionary *rideConfigurationDict = configuration[kRideConfigurationKey];
    if (rideConfigurationDict) {
        if (!self.rideConfiguration) {
            self.rideConfiguration = [DBRideStubConfiguration new];
        }
        NSNumber *rideInitialTime = rideConfigurationDict[kRideInitialTimeKey];
        if (rideInitialTime) {
            self.rideConfiguration.initialTime = rideInitialTime.integerValue;
        }
        NSArray *resources = rideConfigurationDict[kRideResourcesKey];
        if (resources) {
            self.rideConfiguration.resourceFiles = resources;
        }
        NSNumber *statusBeforeCancelled = rideConfigurationDict[kRideStatusBeforeCancelled];
        if (statusBeforeCancelled) {
            self.rideConfiguration.statusBeforeCancelled = (MockRideStatus)statusBeforeCancelled.integerValue;
        }
        NSNumber *whoCancells = rideConfigurationDict[kRideWhoCancells];
        if (whoCancells) {
            self.rideConfiguration.whoCancells = (MockRideStatus)whoCancells.integerValue;
        }
        NSArray *injections = rideConfigurationDict[kRideInjections];
        if (injections.count > 0) {
            NSMutableArray *mInjs = [NSMutableArray array];
            for (NSDictionary *inj in injections) {
                DBRideStubInjection *injection = [DBRideStubInjection new];
                NSNumber *injectionType = inj[kRideInjectionType];
                if (injectionType) {
                    injection.injectionType = (DBRideInjectionType)injectionType.integerValue;
                }
                NSNumber *afterStatus = inj[kRideInjectionAfterStatus];
                if (afterStatus) {
                    injection.injectAfterStatus = (MockRideStatus)afterStatus.integerValue;
                }
                NSNumber *delay = inj[kRideInjectionDelay];
                if (delay) {
                    injection.delay = delay.integerValue;
                }
                NSNumber *timeout = inj[kRideInjectionTimeout];
                if (timeout) {
                    injection.timeout = timeout.integerValue;
                }
                NSString *json = inj[kRideInjectionJSONFile];
                if (json) {
                    injection.injectJSONFile = json;
                }
                
                [mInjs addObject:injection];
            }
            if (self.rideConfiguration.injections.count > 0) {
                NSMutableArray *ma = [NSMutableArray arrayWithArray: self.rideConfiguration.injections];
                [ma addObjectsFromArray:mInjs];
                self.rideConfiguration.injections = [NSArray arrayWithArray:ma];
            }
            else {
                self.rideConfiguration.injections = [NSArray arrayWithArray:mInjs];
            }
        }
    }
}

- (NSDictionary *)configurationWithName:(NSString *)configurationName {
    return self.configurationsDict[configurationName];
}

- (NSArray<NSString *> *)parentsRecursiveTreeFromConfiguration:(NSDictionary *)configuration {
    NSDictionary *configurationTree = [self getParentsFromConfiguration:configuration depth:0];
    NSArray *sortedKeys = [[[[configurationTree allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    
    NSMutableArray<NSString*> *parentsTree = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        NSString *configName = configurationTree[key];
        if (![parentsTree containsObject:configName]) {
            [parentsTree addObject:configName];
        }
    }
    return [NSArray arrayWithArray: parentsTree];
}

- (NSDictionary<NSString*,NSString*> *)getParentsFromConfiguration:(NSDictionary*)configuration depth:(NSUInteger)depth {
    NSMutableDictionary *tree = [NSMutableDictionary dictionary];
    NSArray<NSString*> * rootParents = configuration[kParentsKey];
    for (NSString *child in rootParents) {
        NSDictionary *childConfig = [self configurationWithName:child];
        NSDictionary *configurationTree = [self getParentsFromConfiguration:childConfig depth:depth+1];
        [tree addEntriesFromDictionary:configurationTree];
        NSString *key = [NSString stringWithFormat:@"%lu%@",(unsigned long)depth,child];
        tree[key] = child;
    }
    
    return [NSDictionary dictionaryWithDictionary:tree];
}

@end
