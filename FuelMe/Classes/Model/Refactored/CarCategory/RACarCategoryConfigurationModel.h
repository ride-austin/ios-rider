//
//  RACarCategoryConfigurationModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CategoryBoundaryPolygon.h"
#import "ConfigUTAvailability.h"
#import "RABaseDataModel.h"

@interface RACarCategoryConfigurationModel : RABaseDataModel

@property (nonatomic, readonly) NSArray<CategoryBoundaryPolygon*> *allowedPolygons;
@property (nonatomic, readonly) ConfigUTAvailability *available;

@property (nonatomic, readonly) NSString *zeroFareLabel;
@property (nonatomic, readonly) BOOL showAlert;
@property (nonatomic, readonly) BOOL disableTipping;
@property (nonatomic, readonly) BOOL disableCancellationFee;
@end
