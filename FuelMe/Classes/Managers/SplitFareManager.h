//
//  SplitFareManager.h
//  Ride
//
//  Created by Abdul Rehman on 03/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Contact.h"
#import "SplitFare.h"
#import "SplitFareManagerDefines.h"
#import "SplitResponse.h"

#pragma mark - SplitFarePush Delegate

@protocol SplitFarePushDelegate

//Sender Rider
- (void)splitFarePushAcceptedFromContact:(Contact*)targetContact;
- (void)splitFarePushRejectedFromContact:(Contact*)targetContact;

//Receiver Rider
- (void)splitFarePushRequestedWithId:(NSString*)splitId rideId:(NSString*)rideId fromContact:(Contact*)sender;

@end

#pragma mark - SplitFareManager

@interface SplitFareManager : NSObject

#pragma mark - Properties

@property (strong, nonatomic) NSString *splitID;
@property (weak, nonatomic) id<SplitFarePushDelegate> delegate;

//SplitFares by states
@property (nonatomic) NSMutableArray<SplitFare*> *contactsAccepted;
@property (nonatomic) NSMutableArray<SplitFare*> *contactsRequested;
@property (nonatomic) NSMutableArray<SplitFare*> *contactsDeclined;
@property (nonatomic) NSMutableArray<SplitFare*> *pendingRequests;

#pragma mark - Methods

+(SplitFareManager*)sharedManager;

- (void)respondToSplitRequestWithSPlitResponse:(SplitResponse*)response;
- (void)reloadDataWithRideId:(NSString*)rideID andCompletion:(void (^)(NSError *error, BOOL stopPolling))block;
- (void)sendSplitRequestToContact:(Contact*)contact inRide:(NSString*)rideID withCompletion:(void(^)(id responseObject,NSError *error))completion;
- (void)removeSplitWithSplitID:(NSString*)splitID andCompletion:(void(^)(BOOL))completion;

#pragma mark- Cache management

- (void)checkCachedSplitResponseAndUpdate;

#pragma mark - dataSource

- (NSInteger)totalContacts;
- (NSUInteger)numberOfsections;
- (NSUInteger)numberOfRowsForSection:(NSUInteger)section;
- (NSString *)titleOfHeaderInSection:(NSUInteger)section;
- (SplitFare *)contactForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Polling

typedef void(^RASplitFareReloadBlock)(NSError *error);

@interface SplitFareManager (Polling)

- (void)startPolling;
- (void)startPollingWithReloadCompletion:(RASplitFareReloadBlock)handler;
- (void)stopPolling;

@end
