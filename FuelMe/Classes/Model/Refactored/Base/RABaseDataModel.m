//
//  RABaseDataModel.m
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "RABaseDataModel.h"
#import "GoogleMapsManager.h"
#import "CLLocation+Utils.h"

@interface RABaseDataModel ()

@end

@interface RABaseDataModel (Private)

- (BOOL)canCompareProperty:(id)property withOtherProperty:(id)otherProperty;

@end

@implementation RABaseDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modelID": @"id"
            };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterDB {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return df;
}

- (BOOL)updateProperty:(id)property withOtherProperty:(id)otherProperty {
    if((property == nil || [property isKindOfClass:[NSNull class]]) && (otherProperty != nil && ![otherProperty isKindOfClass:[NSNull class]])) {
        return YES;
    } else if ([self canCompareProperty:property withOtherProperty:otherProperty]) {
        if ([property isKindOfClass:[RABaseDataModel class]]){
            RABaseDataModel *dm1 = (RABaseDataModel*)property;
            RABaseDataModel *dm2 = (RABaseDataModel*)otherProperty;
            return [dm1 updateChanges:dm2];
        } else {
            return ![property isEqual:otherProperty];
        }
    } else {
        return NO;
    }
}

- (BOOL)updateBoolProperty:(BOOL)property withOtherBoolProperty:(BOOL)otherProperty {
    if (property != otherProperty) {
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - Model Protocol

- (BOOL)updateChanges:(RABaseDataModel *)model {
    
    if (![model isMemberOfClass:[self class]]) {
        return NO;
    }
    
    NSArray<NSString*> *propertiesToExclude = [self excludeProperties];
    
    //Get the list hirearchy
    NSMutableArray<Class> *classesToInspect = [NSMutableArray new];
    Class currentClass = [self class];
    while (currentClass && [currentClass isSubclassOfClass:[RABaseDataModel class]]) {
        [classesToInspect addObject:currentClass];
        currentClass = [currentClass superclass];
    }
    
    if ([self respondsToSelector:@selector(willStartUpdatingWithModel:)]) {
        [self willStartUpdatingWithModel:model];
    }
    
    BOOL changed = NO;
    if ([self respondsToSelector:@selector(performCustomUpdateWithModel:)]) {
        changed = [self performCustomUpdateWithModel:model];
    }
    
    for (Class classToInspect in classesToInspect) {
        uint numProperties;
        objc_property_t *properties = class_copyPropertyList(classToInspect, &numProperties);
        for (int i = 0; i < numProperties; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            const char *propAttributes = property_getAttributes(property);
            
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyAttributes = [NSString stringWithUTF8String:propAttributes];
            NSArray  *listAttributes = [propertyAttributes componentsSeparatedByString:@","];
            
            //Debug
            //DBLog(@"Property Name: %@ with attributes : %@",propertyName,propertyAttributes);
            
            //Skip: read-only or properties marked to be excluded
            if (!([listAttributes containsObject:@"R"] || [propertiesToExclude containsObject:propertyName])) {
                id currentValue  = [self valueForKey:propertyName];
                id valueToUpdate = [model valueForKey:propertyName];
                
                //If any of the value is nil, update the property
                BOOL shouldUpdate = ((currentValue && !valueToUpdate) || (!currentValue && valueToUpdate));
                if (shouldUpdate) {
                    [self updateProperty:propertyName withValue:valueToUpdate fromModel:model];
                    changed = YES;
                    continue;
                }
                
                //Both properties has a value
                //If the properties are subclass of RABaseDataModel:: updateProperty:withOtherProperty: update Recursively
                //Other types (ex. Foundation types) are update below in updateProperty:withValue:fromModel:
                if ([self needsSpecialComparisonForProperty:propertyName]) {
                    shouldUpdate = [self shouldUpdateProperty:propertyName usingSpecialComparisonWithNewValue:valueToUpdate];
                } else {
                    shouldUpdate = [self updateProperty:currentValue withOtherProperty:valueToUpdate];
                }
                
                //Update other types (Ex. Foundation Types ~ NSString, NSNumber)
                if (shouldUpdate && ![currentValue isKindOfClass:[RABaseDataModel class]]) {
                    [self updateProperty:propertyName withValue:valueToUpdate fromModel:model];
                }
                
                changed = changed || shouldUpdate;
            }
        }
        free(properties);
    }
    
    if ([self respondsToSelector:@selector(didFinishUpdatingWithModel:)]) {
        [self didFinishUpdatingWithModel:model];
    }
    
    return changed;
}

- (void)updateProperty:(NSString*)propertyName withValue:(id)value fromModel:(RABaseDataModel*)model {
    [self setValue:value forKey:propertyName];
    if ([self respondsToSelector:@selector(didUpdatePropertyWithName:fromModel:)]) {
        [self didUpdatePropertyWithName:propertyName fromModel:model];
    }
}

- (BOOL)needsSpecialComparisonForProperty:(NSString *)name {
    return NO;
}

- (BOOL)shouldUpdateProperty:(NSString *)name usingSpecialComparisonWithNewValue:(id)value {
    return NO;
}

- (NSArray<NSString*>*)excludeProperties {
    return @[];
}

@end

#pragma mark - Transformer

#import "NSNumber+UTC.h"

@implementation RABaseDataModel (Transformer)

+ (MTLValueTransformer*)stringToNumberTransformer{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *numberString, BOOL *success, NSError *__autoreleasing *error) {
        return [NSNumber numberWithDouble:numberString.doubleValue];
    } reverseBlock:^id(NSNumber *number, BOOL *success, NSError *__autoreleasing *error) {
        return [number stringValue];
    }];
}

+ (MTLValueTransformer*)stringToDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (MTLValueTransformer*)stringToDateTransformerDB {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatterDB dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatterDB stringFromDate:date];
    }];
}

+ (MTLValueTransformer*)numberToDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *dateNumber, BOOL *success, NSError *__autoreleasing *error) {
        return [dateNumber dateFromUTC];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [NSNumber UTCFromDate:date];
    }];
}

+ (MTLValueTransformer*)stringToGMSPathTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *pathString, BOOL *success, NSError *__autoreleasing *error) {
        
        GMSMutablePath *mutablePath = [GMSMutablePath new];
        NSArray * components = [pathString componentsSeparatedByString:@" "];
        for (NSString  *locationComponent in components) {
            CLLocation *location = [CLLocation locationFromString:locationComponent];
            if (location) {
                [mutablePath addCoordinate:location.coordinate];
            }
        }
        
        return mutablePath;
    }];
}

- (GMSMutablePath *)pathFromString:(NSString *)pathString {
    if ([pathString isKindOfClass:[NSString class]]) {
        GMSMutablePath *mutablePath = [GMSMutablePath new];
        NSArray * components = [pathString componentsSeparatedByString:@" "];
        for (NSString  *locationComponent in components) {
            CLLocation *location = [CLLocation locationFromString:locationComponent];
            if (location) {
                [mutablePath addCoordinate:location.coordinate];
            }
        }
        
        return mutablePath;
    } else {
        return nil;
    }
}

@end

#pragma mark - Helper

@implementation RABaseDataModel (Helpers)

+ (BOOL)rideDegrees:(CLLocationDegrees)degrees isEqualToOtherRideDegrees:(CLLocationDegrees)otherDegrees {
    //http://stackoverflow.com/a/1344261
    NSUInteger places = 100000; //5 places
    CLLocationDegrees d1 = floor(degrees * places + 0.5) / places;
    CLLocationDegrees d2 = floor(otherDegrees * places + 0.5) / places;
    
    return (d1 == d2);
}

@end

#pragma mark - Private

@implementation RABaseDataModel (Private)

- (BOOL)canCompareProperty:(id)property withOtherProperty:(id)otherProperty {
    if (property == nil && otherProperty == nil) {
        return NO;
    }
    
    id p1 = property;
    id p2 = otherProperty;
    
    NSString *p1ClassName = NSStringFromClass([property class]);
    NSString *p2ClassName = NSStringFromClass([otherProperty class]);
    
    if ([p1ClassName isEqualToString:@"NSTaggedPointerString"]) {
        return [p2 isKindOfClass:[NSString class]];
    } else if ([p1ClassName isEqualToString:@"NSDecimalNumber"]) {
        return [p2 isKindOfClass:[NSNumber class]];
    }
    
    if ([p2ClassName isEqualToString:@"NSTaggedPointerString"]) {
        return [p1 isKindOfClass:[NSString class]];
    } else if ([p2ClassName isEqualToString:@"NSDecimalNumber"]) {
        return [p1 isKindOfClass:[NSNumber class]];
    }
    
    return [p2 isMemberOfClass:[p1 class]];
}

@end
