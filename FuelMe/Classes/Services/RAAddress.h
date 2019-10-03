//
//  RAAddress.h
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GMSAddress.h>

@interface RAAddress : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *fullAddress;
@property (nonatomic, strong) NSString *visibleAddress;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) CLLocation *location;

- (instancetype)initWithGMSAddress:(GMSAddress*)gmsAddress;
- (instancetype)initWithPlaceMark:(CLPlacemark*)placemark;

@end
