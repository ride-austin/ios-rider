//
//  CarCategoriesManager.m
//  Ride
//
//  Created by Abdul Rehman on 24/08/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "CarCategoriesManager.h"
#import "ConfigurationManager.h"
#import "NSDate+Utils.h"
#import "NSNotificationCenterConstants.h"
#import "RAMacros.h"
#import "RARideRequestManager.h"
#import "RARiderDataModel.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation CarCategoriesManager

#pragma mark - Load Categories Icons

+ (void)prefetchCarCategoryIconsFromCarTypes:(NSArray<RACarCategoryDataModel *>*)allCarTypes {
    for (RACarCategoryDataModel *category in allCarTypes) {
        if (category.sliderIconUrl) {
            [[SDWebImageManager sharedManager] loadImageWithURL:category.sliderIconUrl options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image) {
                    DBLog(@"car icon loaded");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidDownloadSliderImage object:nil];
                }
            }];
        }
    }
}

#pragma mark - Constraints Rules

+ (NSArray<RACarCategoryDataModel *> *)getCategoriesValidForLocation:(CLLocation*)location{
    NSArray<RACarCategoryDataModel *> *allCarTypes = [ConfigurationManager shared].global.carTypes.copy;
    NSMutableArray<RACarCategoryDataModel*> *result = [NSMutableArray array];
    for (RACarCategoryDataModel *category in allCarTypes) {
        if ([category allowedBoundaryContainsCoordinate:location.coordinate] &&
            [self passTimeAvailabilityForCategory:category] &&
            [self requestManagerAllowCategory:category]) {
            [result addObject:category];
        }
    }
    return result;
}

+  (BOOL)passTimeAvailabilityForCategory:(RACarCategoryDataModel *)category {
    if (![category hasAvailabilityRestriction]) {
        return YES;
    }

    NSString *from = category.configuration.available.from;
    NSString *to   = category.configuration.available.to;
    NSString *currentTime = [[NSDate trueDate] convertToStringUsingFormat:@"HH:mm:ss"];
    
    NSDate *fromDateTime = [[self availableFormatter] dateFromString:from];
    NSDate *toDateTime   = [[self availableFormatter] dateFromString:to];
    NSDate *currentDateTime = [[self availableFormatter] dateFromString:currentTime];
    
    return [currentDateTime compare:fromDateTime] == NSOrderedDescending && [currentDateTime compare:toDateTime] == NSOrderedAscending;
}

+ (BOOL)requestManagerAllowCategory:(RACarCategoryDataModel *)category {
    return [[RARideRequestManager sharedManager] allowsCategory:category];
}

#pragma mark - Helpers

+ (NSDateFormatter *)availableFormatter {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    return dateFormatter;
}

+ (RACarCategoryDataModel *)getCategoryByName:(NSString *)name {
    NSArray<RACarCategoryDataModel *> *allCarTypes = [ConfigurationManager shared].global.carTypes.copy;
    for (RACarCategoryDataModel *category in allCarTypes) {
        if ([category.carCategory isEqualToString:name]) {
            return category;
        }
    }
    return nil;
}


@end
