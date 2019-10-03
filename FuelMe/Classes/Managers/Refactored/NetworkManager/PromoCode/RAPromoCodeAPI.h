//
//  RAPromoCodeAPI.h
//  Ride
//
//  Created by Roberto Abreu on 9/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseAPI.h"
#import "RAPromoCode.h"

typedef void (^PromoCodeCompletionBlock)(RAPromoCode* promoCode, NSError *error);

@interface RAPromoCodeAPI : NSObject

+ (void)applyPromoCode:(NSString*)code completion:(PromoCodeCompletionBlock)completion;
+ (void)getMyPromoCodeWithCompletion:(PromoCodeCompletionBlock)completion;

@end
