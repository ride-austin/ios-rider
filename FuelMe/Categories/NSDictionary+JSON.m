//
//  NSDictionary+JSON.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (id)jsonFromResourceName:(NSString *)resourceName {
    return [self jsonFromResourceName:resourceName error:nil];
}

+ (id)jsonFromResourceName:(NSString *)resourceName error:(NSError **)error {
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];

    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    NSAssert(json != nil, @"%@", *error);
    return json;
}

@end
