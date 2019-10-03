//
//  RACustomButton.m
//  Ride
//
//  Created by Kitos on 7/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACustomButton.h"

@interface RACustomButton ()

@property (nonatomic, strong) UIColor *disabledColor;
@property (nonatomic, strong) UIColor *enabledColor;

@end

@implementation RACustomButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.enabledColor = [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:1];
    self.disabledColor = [UIColor lightGrayColor];
    
    
    self.layer.cornerRadius = self.frame.size.height/2.0;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled: enabled];
    [self setBackgroundColor:enabled ? self.enabledColor : self.disabledColor];
}

@end
