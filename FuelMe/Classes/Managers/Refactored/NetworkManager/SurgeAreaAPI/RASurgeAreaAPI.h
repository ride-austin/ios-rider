//
//  RASurgeAreaAPI.h
//  Ride
//
//  Created by Kitos on 17/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"

#import "RASurgeAreaDataModel.h"

typedef void(^RASurgeAreasCompletionBlock)(NSArray <RASurgeAreaDataModel*> *surgeAreas, NSError *error);

@interface RASurgeAreaAPI : RABaseAPI

+ (void)getSurgeAreasAtCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(RASurgeAreasCompletionBlock)handler;

@end
