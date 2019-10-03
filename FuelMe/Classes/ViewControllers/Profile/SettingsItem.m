//
//  SettingsItem.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SettingsItem.h"

#import "NSObject+className.h"

@implementation SettingsItem

+ (instancetype)itemWithTitle:(NSString *)title
                     mainURL:(NSURL *)mainURL {
    
    return [self itemWithTitle:title
                      subtitle:nil
                       mainURL:mainURL
                  secondaryURL:nil
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL {
    
    return [self itemWithTitle:title
                      subtitle:subtitle
                       mainURL:mainURL
                  secondaryURL:nil
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
              didSelectBlock:(voidBlock)didSelectBlock {
    
    return [self itemWithTitle:title
                      subtitle:subtitle
                       mainURL:nil
                  secondaryURL:nil
                didSelectBlock:didSelectBlock];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL {

    return [self itemWithTitle:title
                      subtitle:nil
                       mainURL:mainURL
                  secondaryURL:secondaryURL
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
              didSelectBlock:(voidBlock)didSelectBlock {
    return [self itemWithTitle:title subtitle:nil
                       mainURL:nil
                  secondaryURL:nil
                didSelectBlock:didSelectBlock];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL
              didSelectBlock:(voidBlock)didSelectBlock {
    
    SettingsItem *item = [[SettingsItem alloc] initWithTitle:title
                                                    subtitle:subtitle
                                                     mainURL:mainURL
                                                secondaryURL:secondaryURL
                                           andSelectionBlock:didSelectBlock];
    return item;
}

- (instancetype)initWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL
           andSelectionBlock:(voidBlock)didSelectBlock {
    if (self = [super init]) {
        self.title          = title;
        self.subTitle       = subtitle;
        self.mainURL        = mainURL;
        self.secondaryURL   = secondaryURL;
        self.didSelectBlock = didSelectBlock;
        self.accessoryType  = UITableViewCellAccessoryNone;
    }
    if ([self.title isKindOfClass:[NSString class]]) {
        return self;
    } else {
        return nil;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ title:%@\nsubtitle: %@\nmainURL:%@\nsecondaryURL:%@\nhasBlock:%@>",
            self.className,
            self.title,
            self.subTitle,
            self.mainURL,
            self.secondaryURL,
            self.didSelectBlock?@"YES":@"NO"];
}

@end
