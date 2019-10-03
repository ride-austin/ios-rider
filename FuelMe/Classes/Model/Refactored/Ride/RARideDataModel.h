//
//  RARideDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAActiveDriverDataModel.h"
#import "RABaseDataModel.h"
#import "RACarCategoryDataModel.h"
#import "RAPaymentProvider.h"
#import "RAPrecedingRideDataModel.h"
#import "RARideLocationDataModel.h"
#import "RARideStatus.h"
#import "RARideUpgradeRequestDataModel.h"
#import "RARiderDataModel.h"

@interface RARideDataModel : RABaseDataModel

@property (nonatomic) RARideStatus status;
@property (nonatomic) RARideStatus nextStatus; //used when sent a notification update of inner property and the current status is not updated yet.

@property (nonatomic, strong, nullable) RAActiveDriverDataModel *activeDriver;
@property (nonatomic, strong, nullable) RARiderDataModel *rider;

//This dates could be retrieved from RARideLocationObjects, checking rideStatus (RideCache)
@property (nonatomic, strong, nullable) NSDate *startedDate;
@property (nonatomic, strong, nullable) NSDate *freeCancellationExpiryDate;
@property (nonatomic, strong, nullable) NSDate *cancelledDate;
@property (nonatomic, strong, nullable) NSDate *driverAcceptedDate;
@property (nonatomic, strong, nullable) NSDate *driverReachedDate;
@property (nonatomic, strong, nullable) NSDate *completedDate;
/**
 estimated date of arrival to destination in timestamp e.g. 1517494001074
 */
@property (nonatomic, strong, nullable) NSDate *estimatedCompletionDate;
/**
 warning 'start' and 'end' only returns address and zip, it should return latitude and longitude instead of being in the root josn
 */
@property (nonatomic, strong, nonnull) RARideLocationDataModel *startLocation;
@property (nonatomic, strong, nullable) RARideLocationDataModel *endLocation;

@property (nonatomic, strong, nullable) NSString *comment;

//should deprecate this in favor of RARideLocationDataModel
@property (nonatomic, strong, nullable) NSString *startAddress;
@property (nonatomic, strong, nullable) NSNumber *startLocationLatitude;
@property (nonatomic, strong, nullable) NSNumber *startLocationLongitude;
@property (nonatomic, strong, nullable) NSString *endAddress;
@property (nonatomic, strong, nullable) NSNumber *endLocationLatitude;
@property (nonatomic, strong, nullable) NSNumber *endLocationLongitude;

@property (nonatomic, readonly) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D endCoordinate;

@property (nonatomic, readonly, nullable) CLLocation *observedEndLocation;

//@property (nonatomic, strong) NSNumber *distanceTravelled; //not used
@property (nonatomic, strong, nullable) NSNumber *estimatedTimeToArrive;

@property (nonatomic, strong, nullable) RACarCategoryDataModel *requestedCarType;

@property (nonatomic, strong, nullable) NSNumber *rating; //ride rating

@property (nonatomic, strong, nullable) NSNumber *totalFare;

@property (nonatomic, strong, nullable) NSNumber *surgeFactor;

@property (nonatomic, strong, nullable) NSNumber *cancellationFee;

@property (nonatomic, strong, nullable) NSNumber *driverPayment;
@property (nonatomic, strong, nullable) NSNumber *freeCreditCharged;

@property (nonatomic, strong, nullable) NSNumber *tip;
@property (nonatomic, readonly, nullable) NSNumber *tippingAllowed; //make this bool when everyone is using 4.9
@property (nonatomic, readonly, nullable) NSDate *tipUntil;

@property (nonatomic, strong, nullable) RARideUpgradeRequestDataModel *upgradeRequest;

@property (nonatomic, strong, nullable) NSString *paymentProvider;
@property (nonatomic, strong, nullable) NSURL *bevoBucksUrl;

@property (nonatomic, readonly, getter=isDriverComing) BOOL driverComing;
@property (nonatomic, readonly, getter=isDriverArrived) BOOL driverArrived;
@property (nonatomic, readonly, getter=isOnTrip) BOOL onTrip;
@property (nonatomic, readonly, getter=isRiding) BOOL riding;

@property (nonatomic, nullable) RAPrecedingRideDataModel *precedingRide;

- (BOOL)isRiding:(RARideStatus)status;
- (BOOL)isFinished;
- (void)updateObservedDestinationWithEndLocation:(RARideLocationDataModel* _Nonnull)endLocation;

@end
