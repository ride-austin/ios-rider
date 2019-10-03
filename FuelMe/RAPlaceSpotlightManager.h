//
//  RASpotlightManager.h
//  Ride
//
//  Created by Roberto Abreu on 9/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAFavoritePlace.h"

@interface RAPlaceSpotlightManager : NSObject

+ (BOOL)isSpotlightAvailable;
+ (void)setupSearchIndex;
+ (void)cleanSearchIndexWithCompletion:(void(^)(void))completion;

@end
