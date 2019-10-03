//
//  RACarManager.h
//  Ride
//
//  Created by Carlos Alcala on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACarDataModel;

@interface RACarManager : NSObject

@property (nonatomic, strong, readonly) NSArray <RACarDataModel*>*cars;

- (NSArray *)getYearsWithOrder:(BOOL)ASC andMinYear:(NSNumber*)minYear;
- (NSArray *)getMakesWithOrder:(BOOL)ASC andYear:(NSString*)year;
- (NSArray *)getModelsWithOrder:(BOOL)ASC withMake:(NSString*)make andYear:(NSString*)year;

@end
