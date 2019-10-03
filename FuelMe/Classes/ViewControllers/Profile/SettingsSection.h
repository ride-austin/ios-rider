//
//  SettingsSection.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAWorkFavoritePlace.h"
#import "SettingsItem.h"

typedef NS_ENUM(NSUInteger, SectionType) {
    SectionTypeNormal,
    SectionTypeFavoritePlaces
};

@interface SettingsSection : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSMutableArray<SettingsItem *> *items;
@property (nonatomic) NSArray<RAFavoritePlace *> *places;
@property (nonatomic) SectionType type;

+ (instancetype)sectionWithTitle:(NSString *)title;
+ (instancetype)favoritesSectionWithTitle:(NSString *)title
                                  places:(NSArray<RAFavoritePlace *> *)places;
- (void)addObject:(id)object;
- (NSString *)cellIdentifier;
- (NSInteger)rowCount;

@end
