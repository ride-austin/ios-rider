//
//  RACardManagerMock.h
//  Ride
//
//  Created by Roberto Abreu on 5/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACardDataModel.h"
#import "StripeTokenResponseMock.h"

@interface RACardManagerMock : NSObject

@property (strong, nonatomic) NSMutableArray<RACardDataModel*> *cards;

+ (instancetype)sharedInstance;
- (void)addCardFromStripeToken:(StripeTokenResponseMock*)stripeTokenResponse;
- (void)setPrimaryCardWithId:(NSNumber*)cardId;
- (void)deleteCardWithId:(NSNumber*)cardId;

@end
