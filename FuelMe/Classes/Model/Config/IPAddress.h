//
//  IPAddress.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <CoreLocation/CoreLocation.h>

@interface IPAddress : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSNumber *lon;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSString *city;

- (CLLocation *)location;

@end
