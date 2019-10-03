//
//  RANode.h
//  CategorySliderPrototype
//
//  Created by Roberto Abreu on 9/9/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RACarCategoryDataModel.h"

@interface RANode : CALayer

@property (nonatomic) UIAccessibilityElement *accessibilityElement;
@property (nonatomic,weak) CALayer *priorityLayer;
@property (nonatomic,weak) CATextLayer *titleLayer;
@property (nonatomic,strong) RACarCategoryDataModel *category;

- (id)initWithCategory:(RACarCategoryDataModel*)category;
- (CGRect)frameWithOffset;

@end
