//
//  TestConfigurationManager.h
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestConfiguration.h"

@interface TestConfigurationManager : NSObject

@property (nonatomic, readonly, getter=isTesting) BOOL testing;
@property (nonatomic, readonly) TestConfiguration *configuration;

+ (TestConfigurationManager*)sharedManager;

@end
