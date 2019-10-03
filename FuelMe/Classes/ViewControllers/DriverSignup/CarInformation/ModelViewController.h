//
//  ModelViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//
#import "BaseRegistrationViewController.h"
@class DSFlowController;

@interface ModelViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) DSFlowController *coordinator;

@end
