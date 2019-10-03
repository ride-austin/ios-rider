//
//  ConfigurationManager.h
//  Ride
//
//  Created by Theodore Gonzalez on 10/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigGlobal.h"
#import "ConfigReferRider.h"
#import "RACarCategoryDataModel.h"
#import "RACity.h"
#import "ConfigurationManagerConstants.h"
@interface ConfigurationManager : NSObject

@property (nonatomic, nonnull) ConfigGlobal *global;

+ (instancetype _Nonnull)shared;
+ (void)needsReload;
+ (void)checkConfigurationBasedOnLocation:(CLLocation * _Nullable)location;
+ (CityType)getCurrentCityType;
+ (BOOL)currentCityContainsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  @brief exactly the name of the app
 */
+ (NSString * _Nonnull)localAppName;
/**
 *  @brief name based on city
 */
+ (NSString * _Nonnull)appName;
+ (NSString * _Nonnull)appPrefix;

@end
