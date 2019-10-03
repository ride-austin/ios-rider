//
//  RACharityAPI.h
//  RideAustin
//
//  Created by Kitos on 8/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseAPI.h"

#import "RACharityDataModel.h"

typedef void(^RACharityCompletionBlock)(RACharityDataModel *charity, NSError* error);
typedef void(^RACharitiesAPICompletionBlock)(NSArray <RACharityDataModel*> *charities, NSError* error);

@interface RACharityAPI : RABaseAPI

+ (void)getAllCharitiesWithCompletion:(RACharitiesAPICompletionBlock)handler;

@end
