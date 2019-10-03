//
//  NSString+Ride.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/8/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "NSString+Ride.h"

@implementation NSString (Ride)

+ (NSString*)stringWithPhotoType:(CarPhotoType)type {
    switch (type) {
        case FrontPhoto:
            return @"FRONT";
        case BackPhoto:
            return @"BACK";
        case InsidePhoto:
            return @"INSIDE";
        case TrunkPhoto:
            return @"TRUNK";
            
        default:
            break;
    }
    return nil;
}

@end
