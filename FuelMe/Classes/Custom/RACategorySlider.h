//
//  RACategorySlider.h
//  CategorySliderPrototype
//
//  Created by Roberto Abreu on 9/9/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RACarCategoryDataModel.h"
#import "RACategoryDataSource.h"
#import "RASurgeAreaDataModel.h"

@interface RACategorySlider : UIControl

@property (nonatomic,weak) id<RACategoryDataSource> dataSource;
@property (nonatomic,readonly) RACarCategoryDataModel *selectedCategory;

- (void)moveToCategory:(NSString*)category;

- (void)reloadData;

- (void)reloadSurgeAreas:(NSArray<RASurgeAreaDataModel*>*)surgeAreas;
- (void)clearAllSurgeAreas;
- (void)clearSurgeAreas:(NSArray<RASurgeAreaDataModel*>*)surgeAreas;
- (BOOL)isTouchableArea:(CGPoint)location;

@end
