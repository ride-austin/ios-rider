//
//  RAFavoritePlacesManager.h
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAHomeFavoritePlace.h"
#import "RAWorkFavoritePlace.h"

@interface RAFavoritePlacesManager : NSObject

+ (NSArray<RAFavoritePlace*>*)favoritePlaces;
+ (void)saveFavoritePlace:(RAFavoritePlace*)favPlace;
+ (RAHomeFavoritePlace*)homePlace;
+ (RAWorkFavoritePlace*)workPlace;
+ (NSString *)visibleAddressForCoordinate:(CLLocationCoordinate2D)coordinate;

@end
