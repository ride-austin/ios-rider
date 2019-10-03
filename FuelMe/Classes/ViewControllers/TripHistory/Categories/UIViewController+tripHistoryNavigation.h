//
//  UIViewController+tripHistoryNavigation.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SupportTopic;
@class TripHistoryDataModel;

@interface UIViewController (tripHistoryNavigation)

- (void)showNextScreenForTopic:(SupportTopic *)supportTopic withTripHistory:(TripHistoryDataModel *)tripHistory;

@end
