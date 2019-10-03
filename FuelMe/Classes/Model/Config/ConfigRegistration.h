//
//  ConfigRegistration.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/5/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "RACarManager.h"
#import "RACity.h"
#import "RACityDetail.h"

@interface ConfigRegistration : NSObject
@property (nonatomic) RACity *city;
@property (nonatomic) RACityDetail *cityDetail;
@property (nonatomic) RACarManager *carManager;
/**
 *  @brief terms and conditions loaded from `cityDetail.driverRegistrationTermsURL`
 */
@property (nonatomic) NSString *driverTerms;

+ (instancetype)configWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail;
- (NSString *)appName;

@end
