//
//  RAActiveDriverDataModel.h
//  RideAustin
//
//  Created by Kitos on 2/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RADriverDataModel.h"

@interface RAActiveDriverDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) RADriverDataModel *driver;
@property (nonatomic, strong) NSString *currentZipCode;
@property (nonatomic, strong) NSNumber *heading;
@property (nonatomic, strong) NSNumber *course;
@property (nonatomic, strong) NSNumber *speed;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *timeToReachRider;
@property (nonatomic, strong) NSNumber *distanceToReachRider;
@property (nonatomic, strong) RACarDataModel *selectedCar;
@property (nonatomic, readonly) CLLocation *location;

@end
