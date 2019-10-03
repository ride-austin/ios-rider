//
//  RASurgeAreaDataModel.m
//  Ride
//
//  Created by Kitos on 16/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RASurgeAreaDataModel.h"
#import "RAMacros.h"

@interface RASurgeAreaDataModel ()
{
    GMSPath *_boundary;
}
@property (nonatomic, strong) NSString *csvGeometry;

@end

@implementation RASurgeAreaDataModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RASurgeAreaDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"carCategoriesFactors" : @"carCategoriesFactors",
             @"name" : @"name",
             @"csvGeometry" : @"csvGeometry"
             };
}

- (GMSPath *)boundary {
    if (!_boundary) {
        _boundary = [super pathFromString:self.csvGeometry];
    }
    return _boundary;
}

- (BOOL)boundaryContainsLocation:(CLLocation*)location {
    if (self.boundary) {
        return GMSGeometryContainsLocation(location.coordinate, self.boundary, YES);
    } else {
        DBLog(@"RASurgeAreaDataModel %@ shouldn't have nil csvGeometry",self.name);
        return NO;
    }
}

- (BOOL)isEqual:(id)object {
    
    if (![object isMemberOfClass:[self class]]) {
        return NO;
    }
    
    RASurgeAreaDataModel *tmpSurgeArea = ((RASurgeAreaDataModel*)object);
    return [tmpSurgeArea.modelID intValue] == [self.modelID intValue];
}

@end
