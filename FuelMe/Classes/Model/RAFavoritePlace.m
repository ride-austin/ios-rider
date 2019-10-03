//
//  RAFavoritePlace.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAFavoritePlace.h"

@interface RAFavoritePlace ()

@property (nonatomic, strong) UIImage *blackScaledIcon;
@property (nonatomic, strong) UIImage *grayScaledIcon;

@end

static NSString *const kFavoritePlaceNameCoderKey = @"kFavoritePlaceNameCoderKey";
static NSString *const kFavoritePlaceBlackIconCoderKey = @"kFavoritePlaceBlackIconCoderKey";
static NSString *const kFavoritePlaceGrayIconCoderKey = @"kFavoritePlaceGrayIconCoderKey";

@implementation RAFavoritePlace
@synthesize blackIconName = _blackIconName;
@synthesize grayIconName = _grayIconName;

- (void)setBlackIconName:(NSString *)blackIconName {
    _blackIconName = blackIconName;
    self.blackScaledIcon = nil;
}

- (UIImage *)blackScaledIcon {
    if (!_blackScaledIcon) {
        if (self.blackIconName) {
            _blackScaledIcon = [UIImage imageWithCGImage:[UIImage imageNamed:self.blackIconName].CGImage scale:4.0 orientation:UIImageOrientationUp];
        }
    }
    return _blackScaledIcon;
}

- (void)setGrayIconName:(NSString *)grayIconName {
    _grayIconName = grayIconName;
    self.grayScaledIcon = nil;
}

- (UIImage *)grayScaledIcon {
    if (!_grayScaledIcon) {
        if (self.grayIconName) {
            _grayScaledIcon = [UIImage imageWithCGImage:[UIImage imageNamed:self.grayIconName].CGImage scale:4.0 orientation:UIImageOrientationUp];
        }
    }
    return _grayScaledIcon;

}

@end

@implementation RAFavoritePlace (Coder)

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.name = [coder decodeObjectForKey:kFavoritePlaceNameCoderKey];
        self.blackIconName = [coder decodeObjectForKey:kFavoritePlaceBlackIconCoderKey];
        self.grayIconName = [coder decodeObjectForKey:kFavoritePlaceGrayIconCoderKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.name forKey:kFavoritePlaceNameCoderKey];
    [coder encodeObject:self.blackIconName forKey:kFavoritePlaceBlackIconCoderKey];
    [coder encodeObject:self.grayIconName forKey:kFavoritePlaceGrayIconCoderKey];
}

@end

@implementation RAFavoritePlace (Spotlight)

- (BOOL)hasKeywords {
    return self.keywords.count > 0;
}

- (NSArray *)keywords {
    NSMutableArray *mArray = [NSMutableArray new];
    
    if ([self.name isKindOfClass:NSString.class]) {
        [mArray addObject:self.name];
    }
    
    if ([self.shortAddress isKindOfClass:NSString.class]) {
        [mArray addObject:self.shortAddress];
    }
    
    if ([self.fullAddress isKindOfClass:NSString.class]) {
        [mArray addObject:self.fullAddress];
    }
    
    return mArray;
}

@end
