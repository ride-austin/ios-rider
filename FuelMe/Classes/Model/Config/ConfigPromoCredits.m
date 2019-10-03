//
//  ConfigPromoCredits.m
//  Ride
//
//  Created by Roberto Abreu on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigPromoCredits.h"

@implementation ConfigPromoCredits

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"title" : @"title",
              @"detailTitle" : @"subtitle",
              @"showTotal" : @"showTotal",
              @"showDetail" : @"showDetail",
              @"termDescription" : @"description"
            };
}

@end
