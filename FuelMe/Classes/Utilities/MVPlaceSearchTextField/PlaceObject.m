//
//  PlaceObject.m
//  PlaceSearchAPIDEMO
//
//  Created by Mrugrajsinh Vansadia on 25/04/14.
//  Copyright (c) 2014 Mrugrajsinh Vansadia. All rights reserved.
//

#import "PlaceObject.h"
@interface PlaceObject ()

@end

@implementation PlaceObject

- (instancetype)initWithFullText:(NSAttributedString *)fullText primaryText:(NSAttributedString *)primaryText secondaryText:(NSAttributedString *)secondaryText placeID:(NSString *)placeID types:(NSArray<NSString *> *)types {
    self = [super init];
    if (self) {
        self.attributedFullText = fullText;
        self.attributedPrimaryText = primaryText;
        self.attributedSecondaryText = secondaryText;
        self.placeID = placeID;
        self.types = types;
    }
    return self;
}

- (PlaceIconType)iconType {
    if ([self.types containsObject:@"transit_station"]) {
        return PlaceIconTypeTransit;
    } else {
        return PlaceIconTypeDefault;
    }
}

@end

@implementation PlaceObject(MLPAutoCompletionObject)

- (NSString *)autocompleteString {
    return self.attributedFullText.string;
}

- (NSDictionary *)userInfo {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    mDict[@"description"]      = self.attributedFullText.string;
    mDict[@"reference"]        = self.placeID;
    mDict[@"primaryAddress"]   = self.attributedPrimaryText;
    mDict[@"secondaryAddress"] = self.attributedSecondaryText;
    return mDict;
}

@end
