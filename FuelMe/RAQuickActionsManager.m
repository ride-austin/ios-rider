//
//  RAQuickActionsManager.m
//  Ride
//
//  Created by Roberto Abreu on 10/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAQuickActionsManager.h"

#import "RAFavoritePlacesManager.h"

@implementation RAQuickActionsManager

+ (void)setupQuickActions {
    if (@available(iOS 9, *)) {
        [self cleanQuickActions];
        NSMutableArray *quickActions = [[NSMutableArray alloc] init];
        for (RAFavoritePlace *favoritePlace in [RAFavoritePlacesManager favoritePlaces]) {
            UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithTemplateImageName:favoritePlace.blackIconName];
            UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:[NSString stringWithFormat:@"com.rideaustin.item.%@",favoritePlace.name] localizedTitle:[NSString stringWithFormat:@"Go to %@",favoritePlace.name] localizedSubtitle:nil icon:icon userInfo:nil];
            [quickActions addObject:item];
        }
        [UIApplication sharedApplication].shortcutItems = quickActions;
    }
}

+ (void)cleanQuickActions {
    if (@available(iOS 9, *)) {
        [UIApplication sharedApplication].shortcutItems = nil;
    }
}

@end
