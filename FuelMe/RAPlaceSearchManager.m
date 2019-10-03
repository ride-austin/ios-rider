//
//  RAPlaceSearchManager.m
//  Ride
//
//  Created by Roberto Abreu on 10/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPlaceSearchManager.h"

#import "NSNotificationCenterConstants.h"
#import "RAFavoritePlacesManager.h"
#import "RARecentPlacesManager.h"

@implementation RAPlaceSearchManager

+ (instancetype)sharedInstance {
    static RAPlaceSearchManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RAPlaceSearchManager alloc] init];
    });
    return sharedInstance;
}

- (void)processSearchIndex:(NSString*)searchIndex {
    self.placeSelected = nil;
    if (searchIndex) {
        NSString *placeIdentifier = [[searchIndex componentsSeparatedByString:@"."] lastObject];
        for (RAFavoritePlace *place in [RAPlaceSearchManager searchablePlaces]) {
            if ([place.name isEqualToString:placeIdentifier]) {
                self.placeSelected = place;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlaceSearchSelectedNotification object:nil];
    }
}

#pragma mark - Helpers

+ (NSArray<RAFavoritePlace*> *)searchablePlaces {
    NSMutableArray<RAFavoritePlace*> *placesSearchables = [[NSMutableArray alloc] init];
    if ([RAFavoritePlacesManager favoritePlaces]) {
        [placesSearchables addObjectsFromArray:[RAFavoritePlacesManager favoritePlaces]];
    }
    
    if ([RARecentPlacesManager recentPlaces]) {
        [placesSearchables addObjectsFromArray:[RARecentPlacesManager recentPlaces]];
    }
    return placesSearchables;
}

@end
