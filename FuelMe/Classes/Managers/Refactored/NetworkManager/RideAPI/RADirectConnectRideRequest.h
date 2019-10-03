//
//  RADirectConnectRideRequest.h
//  Ride
//
//  Created by Roberto Abreu on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideRequestAbstract.h"

@interface RADirectConnectRideRequest : RARideRequestAbstract

@property (nonatomic) BOOL hasSurgeArea;
@property (nonatomic) NSString *directConnectId;

@end
