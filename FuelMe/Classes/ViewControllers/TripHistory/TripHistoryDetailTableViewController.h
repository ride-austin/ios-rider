//
//  TripHistoryDetailTableViewController.h
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TripHistoryDataModel.h"

@interface TripHistoryDetailTableViewController : UITableViewController

@property (strong, nonatomic) TripHistoryDataModel *tripHistory;

@end
