//
//  DSUser.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSUser.h"

@implementation DSUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"dateOfBirth" : @"dateOfBirth",
             @"address" : @"address",
             @"firstname" : @"firstname",
             @"lastname" : @"lastname",
             @"middleName" : @"middleName"
             };
}

+ (NSValueTransformer *)dateOfBirthJSONTransformer {
    return [self stringToDateTransformer];
}

+ (NSValueTransformer *)addressJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:DSAddress.class];
}

- (NSString *)fullName {
    if ([self.middleName isKindOfClass:NSString.class]) {
        return [NSString stringWithFormat:@"%@ %@ %@", self.firstname, self.middleName, self.lastname];
    } else {
        return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
    }
}

+ (MTLValueTransformer*)stringToDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    return df;
}

- (BOOL)isValid {
    NSParameterAssert([self.dateOfBirth isKindOfClass:NSDate.class]);
    NSParameterAssert([self.firstname   isKindOfClass:NSString.class]);
    NSParameterAssert([self.lastname    isKindOfClass:NSString.class]);
    return self.address.isValid;
}

@end
