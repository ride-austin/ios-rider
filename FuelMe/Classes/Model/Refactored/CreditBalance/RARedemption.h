//
//  RACreditBalance.h
//  Ride
//
//  Created by Roberto Abreu on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RARedemption : RABaseDataModel

@property (nonatomic) NSString *codeLiteral;
@property (nonatomic) NSNumber *maximumUses;
@property (nonatomic) NSNumber *remainingValue;
@property (nonatomic) NSNumber *timesUsed;
@property (nonatomic) NSDate *expiresOn;

@end
