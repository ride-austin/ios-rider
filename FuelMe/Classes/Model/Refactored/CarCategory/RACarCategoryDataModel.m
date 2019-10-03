//
//  RACarCategoryDataModel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RACarCategoryDataModel.h"

@implementation RACarCategoryDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RACarCategoryDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"baseFare": @"baseFare",
             @"minimumFare": @"minimumFare",
             @"bookingFee" : @"bookingFee",
             @"cancellationFee" : @"cancellationFee",
             @"ratePerMile": @"ratePerMile",
             @"ratePerMinute": @"ratePerMinute",
             @"maxPersons": @"maxPersons",
             @"title": @"title",
             @"carCategory": @"carCategory",
             @"catDescription": @"description",
             @"mapIconUrl" : @"mapIconUrl",
             @"plainIconUrl" : @"plainIconUrl",
             @"sliderIconUrl" : @"fullIconUrl",
             @"order" : @"order",
             @"raFeeFactor" : @"raFeeFactor",
             @"tncFeeRate" : @"tncFeeRate",
             @"processingFee" : @"processingFee",
             @"processingFeeText" : @"processingFeeText",
             @"configuration"     : @"configuration"
            };
}

- (BOOL)isEqual:(id)object{
    return ([object isKindOfClass:[RACarCategoryDataModel class]] && [((RACarCategoryDataModel*)object).title isEqualToString:self.title]);
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)baseFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)minimumFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)bookingFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)cancellationFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMileJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMinuteJSONTransformer {
    return [self stringToNumberTransformer];
}
+ (NSValueTransformer *)configurationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return [MTLJSONAdapter modelOfClass:RACarCategoryConfigurationModel.class fromJSONDictionary:json error:nil];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[RACarCategoryConfigurationModel class]]) {
            NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSData *dataRepresentation = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
                NSString *string = [[NSString alloc] initWithData:dataRepresentation encoding:NSUTF8StringEncoding];
                return string;
            }
            NSAssert(*error == nil, @"RAEventParameters reverseBlock failed with error: %@", *error);
        }
        
        return nil;
    }];
}

#pragma mark - Methods

- (BOOL)hasBoundaryRestriction {
    return self.configuration.allowedPolygons && self.configuration.allowedPolygons.count > 0;
}

- (BOOL)allowedBoundaryContainsCoordinate:(CLLocationCoordinate2D)coordinate {
    if (![self hasBoundaryRestriction]) {
        return YES;
    }
    
    for (CategoryBoundaryPolygon *boundaryPolygon in self.configuration.allowedPolygons) {
        if ([boundaryPolygon containsCoordinate:coordinate]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)disableTipping {
    return self.configuration.disableTipping;
}

- (BOOL)hasCancellationFee {
    return self.configuration.disableCancellationFee == NO;
}

- (BOOL)hasAvailabilityRestriction {
    return self.configuration.available.from != nil && self.configuration.available.to != nil;
}

- (NSString *)zeroFareLabel {
    return self.configuration.zeroFareLabel;
}

- (NSNumber*)baseFareApplyingSurge {
    if (self.highestSurgeArea) {
        double baseFareWithSurge = self.baseFare.doubleValue * [self factorForHighestSurgeArea];
        return [NSNumber numberWithFloat:baseFareWithSurge];
    }
    return self.baseFare;
}

- (NSNumber*)minimumFareApplyingSurge {
    if (self.highestSurgeArea) {
        double minimumFareWithSurge = self.minimumFare.doubleValue * [self factorForHighestSurgeArea];
        return [NSNumber numberWithFloat:minimumFareWithSurge];
    }
    return self.minimumFare;
}

- (NSNumber*)ratePerMinuteApplyingSurge {
    if (self.highestSurgeArea) {
        double ratePerMinuteWithSurge = self.ratePerMinute.doubleValue * [self factorForHighestSurgeArea];
        return [NSNumber numberWithFloat:ratePerMinuteWithSurge];
    }
    return self.ratePerMinute;
}

- (NSNumber*)ratePerMileApplyingSurge {
    if (self.highestSurgeArea) {
        CGFloat ratePerMileWithSurge = self.ratePerMile.floatValue * [self factorForHighestSurgeArea];
        return [NSNumber numberWithFloat:ratePerMileWithSurge];
    }
    return self.ratePerMile;
}

@end

#pragma mark - SurgeArea

@implementation RACarCategoryDataModel (SurgeArea)

- (BOOL)hasPriority {
    return self.highestSurgeArea != nil;
}

- (RASurgeAreaDataModel*)highestSurgeArea {
    if (self.surgeAreas.count == 0) { return nil; }
    
    RASurgeAreaDataModel *maxSurgeArea = self.surgeAreas.firstObject;
    for (int i = 1; i < self.surgeAreas.count; i++) {
        RASurgeAreaDataModel *tmpSurgeArea = [self.surgeAreas objectAtIndex:i];
        if ([self factorInCurrentCategoryForSurgeArea:tmpSurgeArea] > [self factorInCurrentCategoryForSurgeArea:maxSurgeArea]) {
            maxSurgeArea = tmpSurgeArea;
        }
    }
    
    return [self factorInCurrentCategoryForSurgeArea:maxSurgeArea] > 1.0 ? maxSurgeArea : nil;
}

- (void)clearSurgeAreas {
    [self.surgeAreas removeAllObjects];
}

- (void)processSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas {
    for (RASurgeAreaDataModel *surgeArea in surgeAreas) {
        if ([self hasFactorInCurrentCategoryForSurgeArea:surgeArea]) {
            if ([self.surgeAreas containsObject:surgeArea]) {
                NSUInteger surgeAreaIndex = [self.surgeAreas indexOfObject:surgeArea];
                [self.surgeAreas replaceObjectAtIndex:surgeAreaIndex withObject:surgeArea];
            } else {
                if (!self.surgeAreas) {
                    self.surgeAreas = [NSMutableArray array];
                }
                [self.surgeAreas addObject:surgeArea];
            }
        } else {
            [self.surgeAreas removeObject:surgeArea];
        }
    }
}

- (double)factorForHighestSurgeArea {
    return [self factorInCurrentCategoryForSurgeArea:self.highestSurgeArea];
}

- (double)factorInCurrentCategoryForSurgeArea:(RASurgeAreaDataModel *)surgeArea {
    NSNumber *surgeFactor = surgeArea.carCategoriesFactors[self.carCategory];
    return MAX(1, surgeFactor.doubleValue);
}

- (BOOL)hasFactorInCurrentCategoryForSurgeArea:(RASurgeAreaDataModel *)surgeArea {
    return [self factorInCurrentCategoryForSurgeArea:surgeArea] > 1;
}

@end
