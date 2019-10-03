//
//  StripeTokenResponseMock.h
//  Ride
//
//  Created by Roberto Abreu on 5/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StripeTokenResponseMock : NSObject

@property (strong, nonatomic) NSNumber *expirationMonth;
@property (strong, nonatomic) NSNumber *expirationYear;
@property (strong, nonatomic) NSString *lastFour;
@property (strong, nonatomic) NSString *cvc;
@property (nonatomic, readonly) NSString *cardBrandByCVC;

- (instancetype)initWithDictionary:(NSDictionary*)dict;
- (instancetype)initWithCVC:(NSString*)cvc lastFour:(NSString*)lastFour expirationMoth:(NSNumber*)expMonth expirationYear:(NSNumber*)expYear;
- (NSData*)dataJSON;

@end
