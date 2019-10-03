//
//  SplitFareTableViewCell.h
//  Ride
//
//  Created by Roberto Abreu on 1/17/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitFareTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end
