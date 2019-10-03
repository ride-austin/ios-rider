//
//  CreditDetailCollectionViewCell.h
//  Ride
//
//  Created by Roberto Abreu on 8/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedemptionViewModel.h"

@interface CreditDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiration;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblCodeValue;

- (void)configureWithViewModel:(RedemptionViewModel *)redemptionViewModel;

@end
