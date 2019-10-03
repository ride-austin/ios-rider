//
//  RARecentPlacesManager.m
//  Ride
//
//  Created by Kitos on 22/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARecentPlacesManager.h"

#import "PersistenceManager.h"
#import "RAPlaceSpotlightManager.h"

static NSUInteger const kDefaultMaxPLaces = 10;
static NSString *kRecentPlacesUDKey = @"kRecentPlacesUDKey";

@implementation RARecentPlacesManager

+ (NSArray<RARecentPlace *> *)recentPlaces {
    NSString *key = [PersistenceManager appendUserToKey:kRecentPlacesUDKey];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (data) {
        NSArray<RARecentPlace*> *recentPlaces = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSMutableArray *validRecentPlaces = recentPlaces.mutableCopy;
        for (RARecentPlace *place in recentPlaces) {
            if (![place isRecentPlaceValid]) {
                [validRecentPlaces removeObject:place];
            }
        }
        return validRecentPlaces;
    }
    
    return nil;
}

+ (void)addRecentPlace:(RARecentPlace *)place {
    if ([place isRecentPlaceValid]) {
        NSMutableArray *recentPlaces = [[self recentPlaces] mutableCopy];
        if (recentPlaces) {
            
            for (int i = 0; i < recentPlaces.count; i++) {
                RARecentPlace *recentPlace = recentPlaces[i];
                BOOL found = [recentPlace isEqualToPlace:place] || [recentPlace isSimilarToPlace:place];
                if (found) {
                    [recentPlaces removeObjectAtIndex:i];
                    break;
                }
            }
            
            [recentPlaces insertObject:place atIndex:0];
            
            if (recentPlaces.count > kDefaultMaxPLaces) {
                [recentPlaces removeLastObject];
            }
            
        } else {
            recentPlaces = [NSMutableArray arrayWithObject:place];
        }
        
        [self saveRecentPlaces:recentPlaces];
        [RAPlaceSpotlightManager setupSearchIndex];
    }
}

+ (void)saveRecentPlaces:(NSArray<RARecentPlace *> *)recentPlaces {
    NSString *key = [PersistenceManager appendUserToKey:kRecentPlacesUDKey];
    if (key) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:recentPlaces];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
