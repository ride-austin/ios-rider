//
//  RABaseDataModel.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Mantle/Mantle.h>

@class RABaseDataModel;
@class GMSMutablePath;

@protocol RADataModelProtocol <NSObject>

- (NSArray<NSString*>*)excludeProperties;
- (BOOL)updateChanges:(RABaseDataModel*)model;

@optional
- (BOOL)needsSpecialComparisonForProperty:(NSString*)name;
- (BOOL)shouldUpdateProperty:(NSString*)name usingSpecialComparisonWithNewValue:(id)value;
- (void)didUpdatePropertyWithName:(NSString*)name fromModel:(RABaseDataModel*)model;
- (void)willStartUpdatingWithModel:(RABaseDataModel*)model;
- (void)didFinishUpdatingWithModel:(RABaseDataModel*)model;
- (BOOL)performCustomUpdateWithModel:(RABaseDataModel*)model;

@end

@interface RABaseDataModel : MTLModel <MTLJSONSerializing, RADataModelProtocol>

@property (nonatomic, strong) NSNumber *modelID;

+ (NSDateFormatter *)dateFormatter;

- (BOOL)updateProperty:(id)property withOtherProperty:(id)otherProperty;
- (BOOL)updateBoolProperty:(BOOL)property withOtherBoolProperty:(BOOL)otherProperty;

@end

@interface RABaseDataModel (Transformer)

+ (MTLValueTransformer*)stringToNumberTransformer;
+ (MTLValueTransformer*)stringToDateTransformer;
+ (MTLValueTransformer*)stringToDateTransformerDB;
+ (MTLValueTransformer*)numberToDateTransformer;
+ (MTLValueTransformer*)stringToGMSPathTransformer;
- (GMSMutablePath *)pathFromString:(NSString *)pathString;

@end

@interface RABaseDataModel (Helpers)

+ (BOOL)rideDegrees:(CLLocationDegrees)degrees isEqualToOtherRideDegrees:(CLLocationDegrees)otherDegrees;

@end
