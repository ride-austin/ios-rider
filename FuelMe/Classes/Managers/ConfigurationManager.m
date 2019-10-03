//
//  ConfigurationManager.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigurationManager.h"

#import "CarCategoriesManager.h"
#import "ErrorReporter.h"
#import "LocationService.h"
#import "NSDictionary+JSON.h"
#import "PersistenceManager.h"
#import "RAConfigAPI.h"
#import "RADriverAPI.h"
#import "RADriverTypeDataModel.h"
#import "RARideRequestManager.h"
#import "RASessionManager.h"

NSString* const kNotificationDidChangeConfiguration = @"kNotificationDidChangeConfiguration";
NSString* const kNotificationDidChangeCurrentCityType = @"kNotificationDidChangeCurrentCityType";
NSString* const kNotificationDidChangeTippingSettings = @"kNotificationDidChangeTippingSettings";

@interface ConfigurationManager()

@property (nonatomic) BOOL needsReconfiguration;
@property (nonatomic) BOOL isWomanOnlyEnabled;
@end

@implementation ConfigurationManager

+ (instancetype)shared {
    static ConfigurationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([PersistenceManager hasConfigGlobal]) {
            _global = [PersistenceManager cachedConfigGlobal];
        } else {
            _global = [ConfigurationManager defaultConfig];
        }
        _needsReconfiguration = YES;
    }
    return self;
}

+ (ConfigGlobal *)defaultConfig {
    NSString* path = @"AustinConfigGlobal";
    NSDictionary *json = [NSDictionary jsonFromResourceName:path];
    return [RAJSONAdapter modelOfClass:ConfigGlobal.class fromJSONDictionary:json isNullable:NO];
}

- (void)setGlobal:(ConfigGlobal *)global {
    BOOL didChange = _global.currentCity.cityType != global.currentCity.cityType;
    _global = global;
    if (didChange) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeCurrentCityType object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeConfiguration object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeTippingSettings object:global.tipping];
    
    [CarCategoriesManager prefetchCarCategoryIconsFromCarTypes:global.carTypes]; //RA-5524 Load Categories on config change (cityID based data)
    [PersistenceManager saveConfigGlobal:global]; //RA-5571 - save global config on persistence
}

+ (void)needsReload {
    [ConfigurationManager shared].needsReconfiguration = YES;
}

+ (void)checkConfigurationBasedOnLocation:(CLLocation *)location {
    if([[RASessionManager sharedManager] isSignedIn]) {
        [[ConfigurationManager shared] checkConfigurationBasedOnLocation:location];
    }
}

- (void)checkConfigurationBasedOnLocation:(CLLocation *)location {
    if (self.needsReconfiguration) {
        __weak __typeof__(self) weakself = self;
        
        if ([location isKindOfClass:[CLLocation class]]) {
            self.needsReconfiguration = NO;
            [RAConfigAPI getGlobalConfigurationAtCoordinate: location.coordinate withCompletion:^(ConfigGlobal *globalConfig, NSError *error) {
                if (error) {
                    weakself.needsReconfiguration = YES;
                } else {
                    weakself.global = globalConfig;
                }
            }];
        } else {
            [LocationService getLocationBasedOnIPAddressWithCompletion:^(CLLocation *location, NSError *error) {
                if (location) {
                    [weakself checkConfigurationBasedOnLocation:location];
                }
            }];
        }
    }
}

#pragma mark - City configuration

+ (CityType)getCurrentCityType {
    return [ConfigurationManager shared].global.currentCity.cityType;
}

#pragma mark - Application Name

+ (NSString *)localAppName {
    NSString *name = [[NSBundle mainBundle].infoDictionary objectForKey:(NSString*)kCFBundleNameKey];
    return name;
}

+ (NSString *)appName {
    return [ConfigurationManager shared].global.generalInfo.appName ?: [ConfigurationManager localAppName];
}

+ (NSString *)appPrefix {
    NSString *cityName = [ConfigurationManager shared].global.currentCity.name;
    if (cityName && cityName.length > 0) {
        NSString *firstLetter = [cityName substringToIndex:1].uppercaseString;
        return [NSString stringWithFormat:@"R%@",firstLetter];
    } else {
        return @"RA";
    }
}

+ (BOOL)currentCityContainsCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[ConfigurationManager shared].global.currentCity containsCoordinate:coordinate];
}

@end
