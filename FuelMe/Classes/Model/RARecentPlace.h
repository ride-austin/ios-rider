//
//  RARecentPlace.h
//  Ride
//
//  Created by Kitos on 22/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAFavoritePlace.h"

@interface RARecentPlace : RAFavoritePlace

@end

@interface RARecentPlace (Validation)

-(BOOL)isRecentPlaceValid;

@end
