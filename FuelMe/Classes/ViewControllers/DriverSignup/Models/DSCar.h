//
//  DSCar.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface DSCar : MTLModel <MTLJSONSerializing>

@property (nonatomic, nullable) NSNumber *modelID; //nullable when create manually
@property (nonatomic) NSString *color;
@property (nonatomic) NSString *license;
@property (nonatomic) NSString *make;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *year;

@end
