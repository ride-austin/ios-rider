//
//  RARiderAPI.h
//  RideAustin
//
//  Created by Kitos on 8/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseAPI.h"
#import "RARedemption.h"
#import "RARiderDataModel.h"
#import "RAUnpaidBalance.h"

typedef void(^RARiderCompletionBlock)(RARiderDataModel *_Nullable rider, NSError * _Nullable error);
typedef void(^PrimaryCardBlock)(NSError *_Nullable error);
typedef PrimaryCardBlock DeleteCardBlock;
typedef void(^CardCreatedBlock)(RACardDataModel *_Nullable card,NSError *_Nullable error);
typedef void(^UnpaidBalanceBlock)(RAUnpaidBalance *_Nullable unpaidBalance, NSError *_Nullable error);
typedef void(^RedemptionsBlock)(NSArray<RARedemption*> *_Nullable redemptions, NSError *_Nullable error);

@interface RARiderAPI : RABaseAPI

+ (void)getCurrentRiderWithCompletion:(RARiderCompletionBlock _Nonnull)handler;
+ (void)updateRider:(RARiderDataModel* _Nonnull)rider completion:(NetworkCompletionBlock _Nonnull)handler;

@end

@interface RARiderAPI (Charity)

+ (void)updateCurrentRiderCharity:(RACharityDataModel* _Nullable)charity withCompletion:(NetworkCompletionBlock _Nonnull)handler;

@end

@interface RARiderAPI (Cards)

+ (void)addCardForRider:(NSString* _Nonnull)riderId token:(NSString* _Nonnull)cardToken withCompletion:(CardCreatedBlock _Nonnull)handler;
+ (void)setPrimaryCard:(RACardDataModel* _Nonnull)card toRider:(NSString* _Nonnull)riderId withCompletion:(PrimaryCardBlock _Nonnull)handler;
+ (void)deleteCard:(RACardDataModel* _Nonnull)card fromRider:(NSString* _Nonnull)riderId withCompletion:(DeleteCardBlock _Nonnull)handler;
+ (void)updateCard:(RACardDataModel *_Nonnull)card forRideWithId:(NSString * _Nonnull)riderId expMonth:(NSString *_Nullable)month expYear:(NSString *_Nullable)year withCompletion:(APIErrorResponseBlock _Nonnull)handler;

@end

@interface RARiderAPI (UnpaidBalance)

+ (void)payUnpaidBalanceForRiderWithId:(NSString* _Nonnull)riderId rideId:(NSString* _Nonnull)rideId applePayToken:(NSString* _Nullable)applePayToken completion:(APIErrorResponseBlock _Nonnull)handler;

@end

@interface RARiderAPI (CreditBalance)

+ (void)redemptionsRemainderForRiderWithId:(NSString* _Nonnull)riderId completion:(APIResponseBlock _Nonnull)completion;
+ (void)redemptionsForRiderWithId:(NSString* _Nonnull)riderId completion:(RedemptionsBlock _Nonnull)completion;

@end
