//
//  RAEventDataModel.m
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAEventDataModel.h"

#import "RAEventParameters.h"

@interface RAEventDataModel()

@property (nonatomic, readwrite, nullable, copy) RAEventParameters *parameters;

@end

@implementation RAEventDataModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RAEventDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"type": @"eventType",
             @"parameters" : @"parameters"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"SURGE_AREA_UPDATE" : @(RAEventSurgeAreaUpdate),
                                                                           @"SURGE_AREA_UPDATES" : @(RAEventSurgeAreaUpdates)
                                                                           }
                                                            defaultValue:@(RAEventUnknown)
                                                     reverseDefaultValue:nil];
}

+ (NSValueTransformer*)parametersJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:NSString.class]) {
            NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:error];
            NSAssert(*error == nil, @"RAEventParameters failed with error: %@", *error);
            if ([params isKindOfClass:NSDictionary.class]) {
                RAEventParameters *object = [MTLJSONAdapter modelOfClass:RAEventParameters.class fromJSONDictionary:params error:error];
                NSAssert(*error == nil, @"RAEventParameters failed with error: %@", *error);
                return object;
            }
        }
        return nil;
    } reverseBlock:^id(RAEventParameters *parameters, BOOL *success, NSError *__autoreleasing *error) {
        if ([parameters isKindOfClass:RAEventParameters.class]) {
            NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:parameters error:error];
            if ([json isKindOfClass:NSDictionary.class]) {
                NSData *dataRepresentation = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
                NSString *string = [[NSString alloc] initWithData:dataRepresentation encoding:NSUTF8StringEncoding];
                return string;
            }
            NSAssert(*error == nil, @"RAEventParameters reverseBlock failed with error: %@", *error);
        }
        
        return nil;
    }];
}

@end

#pragma mark - RAEventsProtocol

@implementation RAEventDataModel (RASurgeAreasEventProtocol)

- (NSArray<RASurgeAreaDataModel *> *)updatedSurgeAreas {
    return self.parameters.surgeAreas;
}

@end


@implementation RAEventDataModel (RASurgeAreaEventProtocol)

- (RASurgeAreaDataModel *)updatedSurgeArea {
    return self.parameters;
}

@end

