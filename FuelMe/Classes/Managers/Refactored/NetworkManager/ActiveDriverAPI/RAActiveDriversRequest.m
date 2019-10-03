//
//  RAActiveDriversRequest.m
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAActiveDriversRequest.h"

@implementation RAActiveDriversRequest

- (id)copyWithZone:(NSZone *)zone {
    RAActiveDriversRequest *request = [[RAActiveDriversRequest alloc] init];
    request.location = self.location;
    request.carCategory = [self.carCategory copy];
    request.womanOnlyMode = self.womanOnlyMode;
    request.isFingerPrintedDriverOnlyMode = self.isFingerPrintedDriverOnlyMode;
    return request;
}

@end
