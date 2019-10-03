//
//  RideCostDetailTableViewCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideCostDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbValue;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;

@end
