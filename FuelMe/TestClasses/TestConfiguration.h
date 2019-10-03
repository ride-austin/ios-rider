//
//  TestConfiguration.h
//  RideAustinTest-Automation
//
//  Created by Roberto Abreu on 11/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRideStubConfiguration.h"
#import "RACity.h"

@interface TestConfiguration : NSObject

@property (nonatomic) BOOL shouldClearCache;
@property (nonatomic) BOOL useStubs;  // Child overrides parent(s).
@property (nonatomic) BOOL registrationStickerEnabled;
@property (nonatomic) NSArray<NSString*> *stubMethods; // Still not in configurations file. It uses different file.
@property (nonatomic) BOOL useRealAuthentication; // Child overrides parent(s).
@property (nonatomic) NSTimeInterval logoutDelay; // Negative value means to not use. Child overrides parent(s).
@property (nonatomic) NSTimeInterval networkUnreachableDelay; // Negative value means to not use. Child overrides parent(s).
@property (nonatomic) CityType city; // Child overrides parent(s).
@property (nonatomic) DBRideStubConfiguration *rideConfiguration; // Child overrides parent except for injections. Injections are added to parent(s) ones.

- (void)loadConfigurationFromFile:(NSString *)name;

@end
