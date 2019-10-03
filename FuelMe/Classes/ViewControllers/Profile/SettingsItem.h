//
//  SettingsItem.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^voidBlock)(void);

@interface SettingsItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) NSURL *mainURL;
@property (nonatomic) NSURL *secondaryURL;
@property (nonatomic, copy) voidBlock didSelectBlock;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;

/**
 *  @brief SettingsViewController will check mainURL, secondaryURL then didSelectBlock which ever is valid first
 */
+ (instancetype)itemWithTitle:(NSString *)title
                      mainURL:(NSURL *)mainURL;

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                      mainURL:(NSURL *)mainURL;

+ (instancetype)itemWithTitle:(NSString *)title
                      mainURL:(NSURL *)mainURL
                 secondaryURL:(NSURL *)secondaryURL;

+(instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
              didSelectBlock:(voidBlock)didSelectBlock;

+ (instancetype)itemWithTitle:(NSString *)title
               didSelectBlock:(voidBlock)didSelectBlock;
@end
