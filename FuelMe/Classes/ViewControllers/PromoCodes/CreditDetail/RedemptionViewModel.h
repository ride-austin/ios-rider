//
//  RedemptionViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RARedemption.h"

@interface RedemptionViewModel : NSObject

@property (nonatomic, readonly) NSString *couponCode;
@property (nonatomic, readonly) NSString *value;
@property (nonatomic, readonly) NSString *descriptionUses;
@property (nonatomic, readonly) NSString *descriptionExpiration;

- (instancetype)initWithRedemption:(RARedemption *)redemption;

@end
