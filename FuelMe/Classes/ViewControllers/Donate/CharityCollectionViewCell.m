//
//  ImageCollectionViewCell.m
//  Ride
//
//  Created by Tyson Bunch on 6/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "CharityCollectionViewCell.h"

@implementation CharityCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.charityImage.layer.borderWidth = .5;
}

- (void)preareForReuse {
    [super prepareForReuse];
    self.charityImage.image = nil;
    self.checkBox.hidden = YES;
    self.charityName.text = nil;
}

@end
