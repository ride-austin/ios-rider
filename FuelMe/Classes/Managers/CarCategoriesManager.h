//
//  CarCategoriesManager.h
//  Ride
//
//  Created by Abdul Rehman on 24/08/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarCategoryDataModel.h"

@interface CarCategoriesManager : NSObject

+ (void)prefetchCarCategoryIconsFromCarTypes:(NSArray<RACarCategoryDataModel *>*)allCarTypes;
+ (NSArray<RACarCategoryDataModel*>*)getCategoriesValidForLocation:(CLLocation*)location;
+ (RACarCategoryDataModel *)getCategoryByName:(NSString *)name;

@end
