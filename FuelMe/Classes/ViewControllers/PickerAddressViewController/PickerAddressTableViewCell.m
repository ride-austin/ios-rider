//
//  PickerAddressTableViewCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/1/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "PickerAddressTableViewCell.h"
#import "DNA.h"

@implementation PickerAddressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customInit];
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconImageView.tintColor = [UIColor grayIconTint];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont fontWithName:FontTypeRegular size:13.0];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [UILabel new];
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.font = [UIFont fontWithName:FontTypeLight size:13.0];
        _subtitleLabel.numberOfLines = 0;
    }
    return _subtitleLabel;
}

- (void)customInit {
    self.isAccessibilityElement = YES;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.iconImageView];
    
    CGFloat margin = 18;
    CGFloat verticalMargin = 11;
    CGFloat imageWidth = 23;
    [NSLayoutConstraint activateConstraints:
     @[
       [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:margin],
       [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
       [self.iconImageView.widthAnchor constraintEqualToConstant:imageWidth],
       [self.iconImageView.heightAnchor constraintEqualToConstant:imageWidth],
       [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:margin],
       [self.contentView.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:margin],
       [self.titleLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:verticalMargin],
       [self.contentView.centerYAnchor constraintGreaterThanOrEqualToAnchor:self.titleLabel.centerYAnchor],
       [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:0],
       [self.contentView.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.subtitleLabel.bottomAnchor constant:verticalMargin],
       [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
       [self.contentView.trailingAnchor constraintEqualToAnchor:self.subtitleLabel.trailingAnchor constant:margin]
       ]];
}

@end
