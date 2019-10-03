//
//  SupportViewController.h
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"
#import "SupportTopic.h"
#import "TripHistoryDataModel.h"

@interface SupportViewController : BaseViewController

@property (strong, nonatomic) TripHistoryDataModel *tripHistoryDataModel;
@property (strong, nonatomic) SupportTopic *selectedSupportTopic;

@end
