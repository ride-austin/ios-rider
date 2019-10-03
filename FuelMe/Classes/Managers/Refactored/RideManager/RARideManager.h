//
//  RARideManager.h
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBKVOController+RideUtils.h"
#import "RARideDataModel.h"
#import "RARideRequest.h"

#import <KVOController/KVOController.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kNeedCompleteRideErrorDomain;

#pragma mark - KVO Keys
extern NSString *const kRAObservationKeyPath;  //keypath key
extern NSString *const kRAObservationNewValue; //new key
extern NSString *const kRAObservationOldValue; //old key
extern NSString *const kRAKeyPathObserveCurrentRide;            // Current ride
extern NSString *const kRAKeyPathObservePollingError;           // Error while long polling.
extern NSString *const kRAKeyPathObserveCurrentRideStatus;      // Ride 'status' property.
extern NSString *const kRAKeyPathObserveCurrentRideEndLocation; // Ride 'endLocation' property.
extern NSString *const kRAKeyPathObserveEstimatedCompletionDate;// Ride 'estimatedCompletionDate' property
extern NSString *const kRAKeyPathObserveActiveDriverLocation;   // Active driver 'location' property.
extern NSString *const kRAKeyPathObserveUpgradeRequest;         // 'upgradeRequest' property.
extern NSString *const kRAKeyPathObserveUpgradeRequestStatus;   // Upgrade Request 'status' property.
extern NSString *const kRAKeyPathObserveRequestedCarTypeTitle;  // 'requestedCarType.title' property.
extern NSString *const kRAKeyPathObservePrecedingRideStatus;
extern NSString *const kRAKeyPathObservePrecedingRideEndLocation;

@protocol RARidePollingConsumerDelegate;

@interface RARideManager : NSObject

@property (nonatomic, weak) id<RARidePollingConsumerDelegate> pollingConsumerDelegate;

@property (nonatomic) RARideStatus status;
@property (nonatomic, readonly, nullable) RARideDataModel *currentRide;
@property (nonatomic, readonly, nullable) NSError *pollingError;

@property (nonatomic, readonly, getter=isDriverComing) BOOL driverComing;
@property (nonatomic, readonly, getter=isDriverArrived) BOOL driverArrived;
@property (nonatomic, readonly, getter=isOnTrip) BOOL onTrip;
@property (nonatomic, readonly, getter=isRiding) BOOL riding;

+ (RARideManager*)sharedManager;

- (BOOL)isRiding:(RARideStatus)status;

@end

#pragma mark - Ride Observation

@interface RARideManager (Observation)

- (void)addObserver:(FBKVOController *)observer withHandler:(RAKVObserveBlock)handler;
- (void)removeObserver:(FBKVOController *)observer;
- (void)addCurrentRideObserver:(FBKVOController*)observer withObservation:(RAKVObserveBlock)handler;
- (void)removeCurrentRideObserver:(FBKVOController*)observer;

@end

#pragma mark - Ride Engine

typedef void(^RARequestRideCompletionBlock)(RARideDataModel * _Nullable ride, NSError * _Nullable error);
typedef void(^RARequestRideStatusCodeCompletionBlock)(NSInteger statusCode, RARideDataModel * _Nullable ride, NSError * _Nullable error);

@interface RARideManager (RideEngine)

- (void)requestRide:(RARideRequestAbstract *)rideRequest completion:(RARequestRideStatusCodeCompletionBlock)handler;
- (void)initiateThirdPartyRideFromQueueToken:(NSString *)queueToken completion: (RARequestRideCompletionBlock)completion;
- (void)reloadRideWithCompletion:(RARequestRideCompletionBlock)handler;
- (void)restoreRide:(NSString*)rideID completion:(RARequestRideCompletionBlock)handler;
- (void)cancelRideWithId:(NSString *)rideId completion:(void(^)(NSError *error))completion;

//This is called automatically for completed, rider_cancelled, driver_cancelled and admin_cancelled ride status, but if an error occurs while polling it only stops timer so that it could be resumed through 'reloadRideWithObserver:handler:andCompletion:' method.
- (void)removeCurrentRide;

- (void)stopPolling; //To start polling again use 'reloadRideWithObserver:handler:andCompletion:' or 'restorRide:withObserver:handler:andCompletion:'
- (void)pauseRidePolling;
- (void)resumeRidePolling;

@end

#pragma mark - Ride Updates 

typedef void(^RARideUpdateCompletionBlock)(NSError* error);

@interface RARideManager (RideUpdates)

- (void)updateDestination:(RARideLocationDataModel*)destination completion:(RARideUpdateCompletionBlock)handler;
- (void)updateComment:(NSString *)comment completion:(RARideUpdateCompletionBlock)handler;

@end

#pragma mark - Consumer

@protocol RARidePollingConsumerDelegate <NSObject>

- (void)pollingNeedsSynchronization;

@end

#pragma mark - Utils

@interface RARideManager (Utils)

+ (BOOL)rideCoordinate:(CLLocationCoordinate2D)coord isEqualToOtherRideCoordinate:(CLLocationCoordinate2D)otherCoord;

@end
NS_ASSUME_NONNULL_END
