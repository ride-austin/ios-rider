//
//  RARecentPlacesManager.h
//  Ride
//
//  Created by Kitos on 22/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RARecentPlace.h"

@interface RARecentPlacesManager : NSObject

+ (NSArray<RARecentPlace*>*)recentPlaces;
+ (void)addRecentPlace:(RARecentPlace*)place;

@end
