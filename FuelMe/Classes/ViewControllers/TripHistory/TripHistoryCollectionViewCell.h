//
//  TripHistoryCollectionViewCell.h
//  Ride
//
//  Created by Robert on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripHistoryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *vContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgTripMap;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblCar;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnCampaignProvider;

@end
