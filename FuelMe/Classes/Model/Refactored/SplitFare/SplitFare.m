//
//  SplitFare.m
//  Ride
//
//  Created by Abdul Rehman on 12/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SplitFare.h"

#import "ErrorReporter.h"

@implementation SplitFare

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *properties = @{
                                 @"rideID"     : @"rideId",
                                 @"riderName"  : @"riderFullName",
                                 @"riderPhoto" : @"riderPhoto",
                                 @"status"     : @"status",
                                 @"sourceRiderName" : @"sourceRiderFullName",
                                 @"sourceRiderPhoto" : @"sourceRiderPhotoURL"
                                 };
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:properties];
}

+ (NSValueTransformer *)statusJSONTransformer {
    NSDictionary *status = @{
                                @"ACCEPTED"  : @(SFStatusAccepted),
                                @"DECLINED"  : @(SFStatusDeclined),
                                @"REQUESTED" : @(SFStatusRequested)
                             };
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return status[value] ?: @(SFStatusInvalid);
    }];
}

@end
