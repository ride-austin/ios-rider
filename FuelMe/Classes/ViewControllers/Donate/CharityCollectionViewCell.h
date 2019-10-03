//
//  ImageCollectionViewCell.h
//  Ride
//
//  Created by Tyson Bunch on 6/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharityCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *charityImage;
@property (nonatomic, strong) IBOutlet UIImageView *checkBox;
@property (nonatomic, strong) IBOutlet UILabel *charityName;
@property (nonatomic, strong) IBOutlet UIView *blankView;

@end
