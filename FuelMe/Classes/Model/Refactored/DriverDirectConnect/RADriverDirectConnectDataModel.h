//
//  RADriverDirectConnectDataModel.h
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface RADriverDirectConnectDataModel : RABaseDataModel

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSURL *photoUrl;
@property (nonatomic) NSNumber *rating;
@property (nonatomic) NSArray<NSString *> *categories;
@property (nonatomic) NSDictionary<NSString *, NSNumber *> *factors;

@end

