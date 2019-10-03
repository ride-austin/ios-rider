//
//  DSDriver.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSDriver.h"

@interface DSDriver()

@property (nonatomic, readonly) NSString *type;
 
@end

@implementation DSDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modelID" : @"id",
             @"user" : @"user",
             @"licenseNumber" : @"licenseNumber",
             @"licenseState" : @"licenseState",
             @"licenseExpiryDate" : @"licenseExpiryDate",
             @"insuranceExpiryDate" : @"insuranceExpiryDate",
             @"ssn" : @"ssn",
             @"email" : @"email",
             @"cityId" : @"cityId",
             @"type" : @"type"
             };
}

- (instancetype)initWithEmail:(NSString *)email {
    if (self = [self init]) {
        _email = email;
        _user = [DSUser new];
        _type = @"DRIVER";
    }
    return self;
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:DSUser.class];
}

+ (NSValueTransformer *)licenseExpiryDateJSONTransformer {
    return [self stringToDateTransformer];
}

+ (NSValueTransformer *)insuranceExpiryDateJSONTransformer {
    return [self stringToDateTransformer];
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
    NSParameterAssert(self.modelID == nil);
    NSParameterAssert(self.user.isValid);
    NSParameterAssert([self.ssn     isKindOfClass:NSString.class]);
    NSParameterAssert([self.email   isKindOfClass:NSString.class]);
    NSParameterAssert([self.cityId  isKindOfClass:NSNumber.class]);
    NSParameterAssert([self.licenseNumber isKindOfClass:NSString.class]);
    NSParameterAssert([self.licenseState  isKindOfClass:NSString.class]);
    NSParameterAssert([self.licenseExpiryDate   isKindOfClass:NSDate.class]);
    NSParameterAssert([self.insuranceExpiryDate isKindOfClass:NSDate.class]);
    return YES;
}

@end
