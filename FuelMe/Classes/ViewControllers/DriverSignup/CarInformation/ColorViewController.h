//
//  ColorViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"
@class DSFlowController;

@interface ColorViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) DSFlowController *coordinator;

@end
