//
//  RARideCommentsManager.h
//  Ride
//
//  Created by Marcos Alba on 24/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RARideCommentsManager : NSObject

+ (RARideCommentsManager*)sharedManager;

- (void)storeComment:(NSString*)comment forLocation:(CLLocationCoordinate2D)coordinate;
- (NSString*)commentFromLocation:(CLLocationCoordinate2D)coordinate;

@end
