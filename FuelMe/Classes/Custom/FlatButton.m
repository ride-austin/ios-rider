
//
//  FlatButton.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "FlatButton.h"

#import "UIColor+LightAndDark.h"

@implementation FlatButton

- (void)setup {
    self.color = self.backgroundColor;
    self.highlightColor = [self.color darkerColor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    CGFloat alpha = enabled ? 1.0:0.25;
    CGFloat duration = enabled ? 0.25:0;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = alpha;
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? self.highlightColor : self.color;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? self.selectedColor : self.color;
}

@end
