//
//  ConfigRegistration.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/5/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigRegistration.h"

@implementation ConfigRegistration

- (instancetype)initWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail {
    self = [super init];
    if (self) {
        if (city && cityDetail) {
            self.city = city;
            self.cityDetail = cityDetail;
        } else {
            return nil;
        }
        self.carManager = [RACarManager new];
    }
    return self;
}

+ (instancetype)configWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail {
    ConfigRegistration *config = [[ConfigRegistration alloc] initWithCity:city andDetail:cityDetail];
    return config;
}

- (NSString *)appName {
    return self.city.appName;
}

@end
