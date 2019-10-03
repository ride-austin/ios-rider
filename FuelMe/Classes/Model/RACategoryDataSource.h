//
//  RACategoryDataSource.h
//  CategorySliderPrototype
//
//  Created by Roberto Abreu on 11/9/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarCategoryDataModel.h"

@protocol RACategoryDataSource <NSObject>

- (NSUInteger)numberOfNodesInCategorySlider;
- (RACarCategoryDataModel*)categoryAtIndex:(int)index;
- (NSUInteger)indexForCategory:(RACarCategoryDataModel *)category;
- (void)didTapCategoryHandler;

@end
