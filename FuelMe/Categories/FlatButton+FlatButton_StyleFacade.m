//
//  FlatButton+FlatButton_StyleFacade.m
//  Ride
//
//  Created by Roberto Abreu on 19/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "FlatButton+FlatButton_StyleFacade.h"

#import "AssetCityManager.h"
#import "UIColor+HexUtils.h"

@implementation FlatButton (FlatButton_StyleFacade)

- (void)applyLoginStyle {
    self.tintColor         = [AssetCityManager colorCurrentCity:Foreground];
    self.highlightColor    = [AssetCityManager colorCurrentCity:Foreground];
    self.selectedColor     = [AssetCityManager colorCurrentCity:SecondaryBack];
    self.backgroundColor   = [UIColor clearColor];
    self.color             = [UIColor clearColor];
    self.layer.borderColor = [AssetCityManager colorCurrentCity:Border].CGColor;
    
    [self setTitleColor:[AssetCityManager colorCurrentCity:Foreground] forState:UIControlStateNormal];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateHighlighted];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateSelected];
}

- (void)applyRegisterStyle {
    self.backgroundColor   = [AssetCityManager colorCurrentCity:Background];
    self.tintColor         = [AssetCityManager colorCurrentCity:Foreground];
    self.highlightColor    = [AssetCityManager colorCurrentCity:SecondaryText];
    self.selectedColor     = [AssetCityManager colorCurrentCity:SecondaryText];
    self.layer.borderColor = [AssetCityManager colorCurrentCity:Border].CGColor;
    self.color             = self.backgroundColor;
    
    [self setTitleColor:[AssetCityManager colorCurrentCity:Foreground] forState:UIControlStateNormal];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryBack] forState:UIControlStateHighlighted];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateSelected];
}

- (void)applyCornerButtonStyle {
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
    self.layer.masksToBounds = YES;
    
    self.backgroundColor   = [UIColor whiteColor];
    self.tintColor         = [UIColor colorWithHex:@"#2C323C"];
    self.highlightColor    = [UIColor colorWithHex:@"#DFDFDF"];
    self.selectedColor     = [UIColor colorWithHex:@"#DFDFDF"];
    self.layer.borderColor = [UIColor colorWithHex:@"#DFDFDF"].CGColor;
    self.layer.borderWidth = 1.0;
    self.color             = self.backgroundColor;
    
    [self setTitleColor:[UIColor colorWithHex:@"#2C323C"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHex:@"#2C323C"] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor colorWithHex:@"#2C323C"] forState:UIControlStateSelected];
}

@end
