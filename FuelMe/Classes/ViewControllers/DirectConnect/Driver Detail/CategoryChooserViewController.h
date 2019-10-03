//
//  CategoryChooserViewController.h
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RACarCategoryDataModel.h"

@protocol CategoryChooserDelegate

- (void)didChooseCategoryWithName:(NSString *)name;

@end

@interface CategoryChooserViewController : UIViewController

@property (weak, nonatomic) id<CategoryChooserDelegate> delegate;
@property (nonatomic) RACarCategoryDataModel *categorySelected;
@property (nonatomic) NSArray<NSString *> *carCategories;
@property (nonatomic) NSDictionary<NSString *, NSNumber *> *factors;

@end
