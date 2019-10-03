//
//  CategoryBoundaryPolygon.h
//  Ride
//
//  Created by Roberto Abreu on 8/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
@class GMSPath;
@interface CategoryBoundaryPolygon : RABaseDataModel

@property (nonatomic, readonly) NSString *name;
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;
- (GMSPath *)path;
@end
