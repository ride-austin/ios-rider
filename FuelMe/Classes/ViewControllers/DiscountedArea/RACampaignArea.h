//
//  RACampaignArea.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CategoryBoundaryPolygon.h"
#import <UIKit/UIKit.h>

@interface RACampaignArea : CategoryBoundaryPolygon <MTLJSONSerializing>

- (UIColor *)colorWithAlpha:(CGFloat)alpha;

@end
