//
//  RAPrecedingRideDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 1/29/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RARideStatus.h"

@class RARideLocationDataModel;

@interface RAPrecedingRideDataModel : RABaseDataModel

@property (nonatomic) RARideStatus status;
@property (nonatomic) RARideLocationDataModel *endLocation;

- (CLLocationCoordinate2D)endCoordinate;

@end
