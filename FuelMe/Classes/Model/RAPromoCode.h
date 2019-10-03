//
//  RAPromoCode.h
//  Ride
//
//  Created by Kitos on 7/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface RAPromoCode : RABaseDataModel

@property (nonatomic, readonly) NSString *codeLiteral;
@property (nonatomic, readonly) NSNumber *codeValue;
@property (nonatomic, readonly) NSNumber *currentRedemption;
@property (nonatomic, readonly) NSNumber *maxRedemption;
@property (nonatomic, readonly) NSNumber *totalRedemption;
@property (nonatomic, readonly) NSString *detailText;
@property (nonatomic, readonly) NSString *emailBody;
@property (nonatomic, readonly) NSString *smsBody;
@property (nonatomic, readonly) NSNumber *remainingCredit; //Only available when added a new PromoCode

@end
