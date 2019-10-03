//
//  RAFavoritePlace.h
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RAPlace.h"

@interface RAFavoritePlace : RAPlace

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *blackIconName;
@property (nonatomic, strong) NSString *grayIconName;

@property (nonatomic, readonly) UIImage *blackScaledIcon;
@property (nonatomic, readonly) UIImage *grayScaledIcon;

@end

@interface RAFavoritePlace (Spotlight)

- (BOOL)hasKeywords;
- (NSArray *)keywords;

@end
