//
//  RADriverDirectConnectDataModel.m
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RADriverDirectConnectDataModel.h"

@implementation RADriverDirectConnectDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"firstName"  : @"firstName",
              @"lastName"   : @"lastName",
              @"photoUrl"   : @"photoUrl",
              @"rating"     : @"rating",
              @"categories" : @"categories",
              @"factors"    : @"factors"
            };
}

@end
