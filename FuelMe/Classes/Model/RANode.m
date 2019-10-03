//
//  RANode.m
//  CategorySliderPrototype
//
//  Created by Roberto Abreu on 9/9/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

#import "RANode.h"

#define kNodeColor [UIColor colorWithRed:173.0/255 green:175.0/255 blue:181.0/255 alpha:1.0]

@implementation RANode

- (instancetype)initWithCategory:(RACarCategoryDataModel *)category{
    self = [self init];
    if (self) {
        self.category = category;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.borderColor = kNodeColor.CGColor;
        self.borderWidth = 0.7;
        self.cornerRadius = 7.5;
        self.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (CGRect)frameWithOffset {
    return CGRectInset(self.frame, -15, -15);
}

@end
