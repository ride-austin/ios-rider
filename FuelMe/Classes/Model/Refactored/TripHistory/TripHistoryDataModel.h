//
//  TripHistoryDataModel.h
//  Ride
//
//  Created by Robert on 8/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

typedef enum : NSUInteger {
    TripCompleted,
    TripCancelledByDriver,
    TripCancelledByRider,
    TripCancelledByAdmin,
    TripStatusUnsupported
} TripHistoryStatus;

@interface TripHistoryDataModel : RABaseDataModel

@property (strong, nonatomic) NSNumber *rideId;
@property (readonly, nonatomic) NSString *stripeCreditCharge;
@property (readonly, nonatomic) NSString *rideTotalFare;
@property (strong, nonatomic) NSString *startAddress;
@property (strong, nonatomic) NSString *endAddress;
@property (strong, nonatomic) NSString *cardBrand;
@property (strong, nonatomic) NSString *cardNumber;
@property (assign, nonatomic, getter=isMainRider) BOOL mainRider;
@property (strong, nonatomic) NSString *driverFirstName;
@property (strong, nonatomic) NSString *driverLastName;
@property (readonly, nonatomic) NSString *driverNickName;
@property (strong, nonatomic) NSURL *driverPictureURL;
@property (strong, nonatomic) NSString *riderFirstName;
@property (strong, nonatomic) NSString *riderLastName;
@property (strong, nonatomic) NSURL *riderPictureURL;
@property (strong, nonatomic) NSURL *mapURL;
@property (strong, nonatomic) NSNumber *driverRating;
@property (strong, nonatomic) NSString *carBrand;
@property (strong, nonatomic) NSString *carModel;
@property (readonly, nonatomic) NSURL *otherPaymentMethodUrl;
@property (readonly, nonatomic) NSString *campaignDescriptionHistory;
@property (readonly, nonatomic) NSString *campaignDiscount;
@property (readonly, nonatomic) NSString *campaignProvider;
@property (strong, nonatomic) NSString *tip;


#pragma mark - Helper

- (TripHistoryStatus)status;
- (BOOL)isCancelled;
- (BOOL)hasCreditCardInfo;
- (BOOL)hasCampaign;
- (BOOL)hasTip;

- (NSString *)dateString;
- (NSString *)statusString;
- (NSString *)carInformation;

@end

@interface TripHistoryDataModel(ForDisplay)

- (NSString *)displayName;
- (NSString *)displayDiscount;
- (NSString *)displayRideCost;
- (NSString *)displayTotalCharged;
- (NSString *)displayTip;
@end
