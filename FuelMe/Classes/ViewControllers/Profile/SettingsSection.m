//
//  SettingsSection.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SettingsSection.h"

@implementation SettingsSection

+ (instancetype)sectionWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title
                                  type:SectionTypeNormal
                                places:nil];
}

+ (instancetype)favoritesSectionWithTitle:(NSString *)title places:(NSArray<RAFavoritePlace *> *)places {
    return [[self alloc] initWithTitle:title
                                  type:SectionTypeFavoritePlaces
                                places:places];
}

- (instancetype)initWithTitle:(NSString *)title type:(SectionType)type places:(NSArray<RAFavoritePlace *> *)places {
    if (self = [super init]) {
        self.title  = title;
        self.type   = type;
        self.places = [NSArray arrayWithArray:places];
        self.items  = [NSMutableArray new];
    }
    return self;
}

- (void)addObject:(id)object {
    NSAssert(object != nil, @"SettingsSection cannot add nil");
    if (object) {
        [self.items addObject:object];
    }
}

- (NSString *)cellIdentifier {
    switch (self.type) {
        case SectionTypeFavoritePlaces:
            return @"favoritePlaceCell";
        case SectionTypeNormal:
            return @"SettingsCell";
    }
}

- (NSInteger)rowCount {
    switch (self.type) {
        case SectionTypeNormal:
            return self.items.count;
            
        case SectionTypeFavoritePlaces:
            return self.places.count;
    }
}

@end
