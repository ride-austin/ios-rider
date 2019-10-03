//
//  RARideLocationDataModel.m
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARideLocationDataModel.h"

#import "RAFavoritePlacesManager.h"

@implementation RARideLocationDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        if (!_visibleAddress) {
            NSString *visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:[self coordinate]];
            _visibleAddress = visibleAddress ?: _address;
        }
    }
    return self;
}

- (instancetype)initWithLocation:(CLLocation *)location{
    self = [self initWithCoordinate:location.coordinate];
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate{
    self = [super init];
    if (self) {
        self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    }
    return self;
}

- (instancetype)initWithAddress:(RAAddress *)address {
    if (self = [self initWithLocation:address.location]) {
        self.address = address.address;
        self.visibleAddress = address.visibleAddress;
        self.timestamp = [NSDate date];
    }
    return self;
}

- (void)setAddress:(NSString *)address{
    _address = [address stringByRemovingPercentEncoding];
}

- (void)setVisibleAddress:(NSString *)visibleAddress{
    _visibleAddress = [visibleAddress stringByRemovingPercentEncoding];
}

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (CLLocation *)location{
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}

- (NSString *)completeAddress{
    NSArray *chunks = [self.address componentsSeparatedByString: @","];
    if (chunks.count > 1) {
        return self.address;
    } else {
        if (self.address) {
            NSMutableString * completeAddress = [NSMutableString stringWithString:self.address];
            
            if (self.city) {
                [completeAddress appendString:[NSString stringWithFormat:@", %@",self.city]];
            }
            
            if (self.state) {
                [completeAddress appendString:[NSString stringWithFormat:@", %@",self.state]];
            }
            
            return completeAddress;
        }
    }
    
    return @"";
}

- (void)setLocationByCoordinate:(CLLocationCoordinate2D)coordinate {
    _latitude = [NSNumber numberWithDouble:coordinate.latitude];
    _longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RARideLocationDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"address": @"address",
             @"zipCode": @"zipCode",
             @"latitude": @"latitude",
             @"longitude": @"longitude",
             @"timestamp": @"timestamp"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
