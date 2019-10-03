//
//  RideCostDetailViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACarCategoryDataModel.h"
#import "RAFee.h"
#import "RAPopUpViewController.h"

@interface RideCostDetailViewController : RAPopUpViewController

+ (instancetype)controllerWithCarCategory:(RACarCategoryDataModel*)category andSpecialFees:(NSArray<RAFee *>*)specialFees;

@end
