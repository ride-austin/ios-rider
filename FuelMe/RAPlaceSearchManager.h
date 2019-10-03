//
//  RAPlaceSearchManager.h
//  Ride
//
//  Created by Roberto Abreu on 10/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAFavoritePlace.h"

@interface RAPlaceSearchManager : NSObject

@property (strong, nonatomic) RAFavoritePlace *placeSelected;

+ (instancetype)sharedInstance;
- (void)processSearchIndex:(NSString*)searchIndex;
+ (NSArray<RAFavoritePlace*> *)searchablePlaces;

@end
