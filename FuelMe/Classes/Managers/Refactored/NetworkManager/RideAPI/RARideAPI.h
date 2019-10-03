//
//  RARideAPI.h
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"
#import "RAFee.h"
#import "RARideDataModel.h"
#import "RARideRequest.h"

typedef void(^RARideCompletionBlock)(RARideDataModel * _Nullable ride, NSError * _Nullable error);
typedef void(^RARideStatusCodeCompletionBlock)(NSInteger statusCode, RARideDataModel * _Nullable ride, NSError * _Nullable error);

@interface RARideAPI : RABaseAPI

+ (void)requestRide:(RARideRequestAbstract *)rideRequest withCompletion:(RARideStatusCodeCompletionBlock)handler;
+ (void)postRidesQueue:(NSString * _Nonnull)token withCompletion:(RARideCompletionBlock)completion;
+ (void)cancelRideById:(NSString*)rideID withCompletion:(APIErrorResponseBlock)handler;
+ (void)getRide:(NSString *)rideID andCompletion:(RARideCompletionBlock)handler;
+ (void)getRide:(NSString*)rideID withRiderLocation:(CLLocation *)riderLocation andCompletion:(RARideCompletionBlock)handler;
+ (void)getCurrentRideWithCompletion:(RARideCompletionBlock)handler;
+ (void)updateDestination:(RARideLocationDataModel*)destination forRide:(NSString*)rideID completion:(APIErrorResponseBlock)handler;
+ (void)updateComment:(NSString*)comment forRide:(NSString*)rideID completion:(APIErrorResponseBlock)handler;

@end

@interface RARideAPI (UpgradeRideRequest)

+ (void)declineUpgradingCurrentRideWithCompletion:(APIErrorResponseBlock)handler;
+ (void)confirmUpgradingCurrentRideWithCompletion:(APIErrorResponseBlock)handler;

@end

#import "CFReasonDataModel.h"
@interface RARideAPI (CancellationFeedback)

+ (void)getReasonsWithCompletion:(void(^)(NSArray<CFReasonDataModel *> * _Nullable reasons, NSError * _Nullable error))completion;
+ (void)postReason:(NSString *)reasonCode forRide:(NSNumber *)rideID withComment:(NSString *)comment andCompletion:(void (^)(NSError * _Nullable))completion;

@end

#import "RAEstimate.h"
@interface RARideAPI (Costs)

+ (void)getSpecialFeesAtCoordinate:(CLLocationCoordinate2D)coordinate
                           cityID:(NSNumber *)cityID
                   forCarCategory:(NSString *)carCategory
                   withCompletion:(void(^)(NSArray<RAFee *> * _Nullable specialFees, NSError * _Nullable error))completion;

+ (void)getRideEstimateFromStartLocation:(CLLocationCoordinate2D)startLocation
                          toEndLocation:(CLLocationCoordinate2D)endLocation
                             inCategory:(RACarCategoryDataModel*)category
                         withCompletion:(void (^)(RAEstimate * _Nullable estimate, NSError * _Nullable))completion;

@end

@interface RARideAPI (CompletedRides)

+ (void)getMapForRide:(NSString *)rideID withCompletion:(void (^)(NSURL *mapURL, NSError *error))completion;

/**
 @param paymentProvider if specified as CREDIT_CARD, server will not wait for paymentDelays and immediately charge the primary credit card
 */
+ (void)rateRide:(NSString *)rideID
     withRating:(NSString *)rating
            tip:(NSString *)tip
     andComment:(NSString *)comment
paymentProvider:(NSString *)paymentProvider
 withCompletion:(RARideCompletionBlock)completion;

@end

@interface RARideAPI (RealTimeTracking)

+ (void)getRealTimeTrackingTokenByID:(NSString *)rideID completion:(void(^)(NSString * _Nullable token, NSError * _Nullable error))completion;

@end
