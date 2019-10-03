//
//  DCDriverDetailViewController.h
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RADriverDirectConnectDataModel.h"

@class DCDriverDetailViewController;
@protocol DCDriverDetailViewControllerDelegate
- (BOOL)dcDriverDetailViewControllerCheckLocationPermissions:(DCDriverDetailViewController * _Nullable)dcDriverDetailViewController;
@end

@interface DCDriverDetailViewController : UIViewController

@property (nonatomic, nullable, weak) id delegate;
@property (nonatomic, nonnull) RADriverDirectConnectDataModel *driverDirectConnectDataModel;

//workaround to avoid removing DC KVO observer until RA-14216
@property (assign, nonatomic) BOOL isRequestingDirectConnect;

@end
