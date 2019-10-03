//
//  AppConfig.h
//  Ride
//
//  Created by Roberto Abreu on 2/6/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+ (NSString *)apiKey;
+ (NSString *)googleDirectionsKey;
+ (NSString *)googleMapKey;
+ (NSString *)stripeKey;
+ (NSString *)stripeKeyQA;
+ (NSString *)appleMerchantIdentifier;
+ (NSString *)bugFenderKey;
+ (NSString *)productionServerURL;
+ (NSString *)qaServerURL;
+ (NSString *)stageServerURL;
+ (NSString *)devServerURL;
+ (NSString *)featureServerURL;
+ (NSString *)md5PasswordSalt;

@end
