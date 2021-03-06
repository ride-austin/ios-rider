//
//  SupportTableViewController.h
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SupportTopic.h"
#import "TripHistoryDataModel.h"

@interface SupportTableViewController : UITableViewController

@property (strong, nonatomic) TripHistoryDataModel *tripHistoryDataModel;
@property (strong, nonatomic) SupportTopic *parentTopic;
@property (strong, nonatomic) NSArray<SupportTopic*> *subTopics;

@end
