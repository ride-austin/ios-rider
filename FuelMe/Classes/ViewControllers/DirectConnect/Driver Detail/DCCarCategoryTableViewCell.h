//
//  DCCarCategoryTableViewCell.h
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCCarCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgPriority;
@property (weak, nonatomic) IBOutlet UILabel *lblPriorityMultiplier;

@end
