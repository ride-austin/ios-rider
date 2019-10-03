//
//  SplitFareAPI.h
//  Ride
//
//  Created by Roberto Abreu on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"
#import "SplitFare.h"

typedef void(^SplitFareCompletionBloc)(NSArray<SplitFare*>* splitFares,NSError *error);

@interface SplitFareAPI : RABaseAPI

+ (void)sendSplitFareRequestsToPhoneNumbers:(NSArray<NSString*>*)phoneNumbers inRide:(NSString*)rideID andCompletion:(APIResponseBlock)completion;
+ (void)respondToSplitFareRequestForSplitID:(NSString*)splitID withAcceptance:(BOOL)accepted andCompletion:(APIResponseBlock)completion;
+ (void)getListOfSplitsByRideID:(NSString*)rideID andCompletion:(SplitFareCompletionBloc)completion;
+ (void)removeSplitByID:(NSString*)splitID andCompletion:(APIErrorResponseBlock)completion;
+ (void)getPendingSplitRequestsForCurrentRiderWithCompletion:(SplitFareCompletionBloc)completion;
+ (void)getPendingSplitRequestsForRiderID:(NSString*)riderID withCompletion:(SplitFareCompletionBloc)completion;

@end
