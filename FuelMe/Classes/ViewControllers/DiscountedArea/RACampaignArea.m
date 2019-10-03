//
//  RACampaignArea.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RACampaignArea.h"
#import "UIColor+HexUtils.h"
@interface RACampaignArea()

@property (nonatomic) NSString *color;

@end

@implementation RACampaignArea

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *keyPaths = [super JSONKeyPathsByPropertyKey].mutableCopy;
    keyPaths[@"color"] = @"color";
    return keyPaths;
}

- (UIColor *)colorWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHex:self.color alpha:alpha];
}

@end
