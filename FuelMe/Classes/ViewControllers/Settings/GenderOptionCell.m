//
//  GenderOptionCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GenderOptionCell.h"
#import "DNA.h"

@implementation GenderOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textLabel.font = [UIFont fontWithName:FontTypeRegular size:14.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
