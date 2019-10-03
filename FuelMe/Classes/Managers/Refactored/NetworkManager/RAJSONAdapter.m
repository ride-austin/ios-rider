//
//  RAJSONAdapter.m
//  Ride
//
//  Created by Roberto Abreu on 6/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAJSONAdapter.h"

#import "ErrorReporter.h"

@implementation RAJSONAdapter

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)json isNullable:(BOOL)isNullable {
    if (json == nil && isNullable) {
        return nil;
    } else {
        NSError *error;
        id response = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:json error:&error];
#ifdef TEST
        NSAssert(!error, @"Error while mapping %@ error: %@", NSStringFromClass(modelClass), error);
#endif
        return response;
    }
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)json isNullable:(BOOL)isNullable {
    if (json == nil && isNullable) {
        return nil;
    } else {
        NSError *error;
        id response = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:json error:&error];
#ifdef TEST
        NSAssert(!error, @"Error while mapping %@ error: %@", NSStringFromClass(modelClass), error);
#endif
        return response;
    }
}

@end
