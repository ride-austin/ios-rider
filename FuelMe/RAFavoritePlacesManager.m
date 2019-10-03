//
//  RAFavoritePlacesManager.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAFavoritePlacesManager.h"

#import "PersistenceManager.h"
#import "RAPlaceSpotlightManager.h"
#import "RAQuickActionsManager.h"

static NSString *kHomePlaceUDKey = @"kHomePlaceUDKey";
static NSString *kWorkPlaceUDKey = @"kWorkPlaceUDKey";

@implementation RAFavoritePlacesManager

+ (NSArray<RAFavoritePlace *> *)favoritePlaces{
    NSMutableArray *favoritePlaces = [NSMutableArray array];
    
    RAHomeFavoritePlace *homeFavPlace = [self homePlace];
    if (homeFavPlace) {
        [favoritePlaces addObject:homeFavPlace];
    }
    
    RAWorkFavoritePlace *workFavPlace = [self workPlace];
    if (workFavPlace) {
        [favoritePlaces addObject:workFavPlace];
    }
    
    if(favoritePlaces.count > 0){
        return [NSArray arrayWithArray:favoritePlaces];
    } else {
        return nil;
    }
}

+ (void)saveFavoritePlace:(RAFavoritePlace *)favPlace {
    if ([favPlace isKindOfClass:[RAHomeFavoritePlace class]]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favPlace];
        NSString *key = [PersistenceManager appendUserToKey:kHomePlaceUDKey];
        if (key) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else if ([favPlace isKindOfClass:[RAWorkFavoritePlace class]]){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favPlace];
        NSString *key = [PersistenceManager appendUserToKey:kWorkPlaceUDKey];
        if (key) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [RAPlaceSpotlightManager setupSearchIndex];
    [RAQuickActionsManager setupQuickActions];
}

+ (RAHomeFavoritePlace *)homePlace {
    NSString *key = [PersistenceManager appendUserToKey:kHomePlaceUDKey];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (data) {
        RAHomeFavoritePlace *home = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return  home;
    }
    
    return nil;
}

+ (RAWorkFavoritePlace *)workPlace {
    NSString *key = [PersistenceManager appendUserToKey:kWorkPlaceUDKey];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (data) {
        RAWorkFavoritePlace *work = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return  work;
    }
    
    return nil;
}

+ (NSString *)visibleAddressForCoordinate:(CLLocationCoordinate2D)coordinate {
    const CGFloat epsilon = 1.5;
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    NSArray<RAFavoritePlace*> *favoritePlaces = [self favoritePlaces];
    for (RAFavoritePlace *favoritePlace in favoritePlaces) {
        if ([targetLocation distanceFromLocation:favoritePlace.location] < epsilon) {
            return favoritePlace.name;
        }
    }
    return nil;
}

@end
