//
//  PaymentSectionItem.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PaymentSectionItem.h"

@implementation PaymentSectionItem

- (instancetype)initWithHeader:(NSString *)header footer:(NSString *)footer andRowItems:(NSArray *)rowItems {
    if (self = [super init]) {
        _header = header;
        _footer = footer;
        _rowItems = rowItems;
    }
    return self;
}

+ (instancetype)itemWithHeader:(NSString *)header footer:(NSString *)footer andRowItems:(NSArray *)rowItems {
    return [[self alloc] initWithHeader:header footer:footer andRowItems:rowItems];
}

@end
