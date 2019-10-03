//
//  TripHistoryDataModel.m
//  Ride
//
//  Created by Robert on 8/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TripHistoryDataModel.h"

#import "NSDate+Utils.h"
#import "RAMacros.h"

@interface TripHistoryDataModel ()
@property (nonatomic) NSString *rideStatus;
@property (strong, nonatomic) NSDate *dateCompletedOn;
@property (strong, nonatomic) NSDate *dateCancelledOn;

@end

@implementation TripHistoryDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[TripHistoryDataModel JSONKeyPaths]];

}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"rideId" : @"rideId",
             @"stripeCreditCharge" : @"stripeCreditCharge",
             @"rideTotalFare" : @"rideTotalFare",
             @"startAddress" : @"rideStartAddress",
             @"endAddress" : @"rideEndAddress",
             @"mainRider" : @"mainRider",
             @"rideStatus" : @"rideStatus",
             @"cardBrand" : @"usedCardBrand",
             @"cardNumber" : @"cardNumber",
             @"dateCompletedOn" : @"completedOnUTC",
             @"dateCancelledOn" : @"cancelledOnUTC",
             @"driverFirstName" : @"driverFirstName",
             @"driverLastName" : @"driverLastName",
             @"driverNickName" : @"driverNickName",
             @"driverPictureURL" : @"driverPicture",
             @"riderFirstName" : @"mainRiderFirstName",
             @"riderLastName" : @"mainRiderLastName",
             @"riderPictureURL" : @"mainRiderPicture",
             @"mapURL" : @"mapUrl",
             @"driverRating" : @"driverRating",
             @"carBrand" : @"carBrand",
             @"carModel" : @"carModel",
             @"otherPaymentMethodUrl" : @"otherPaymentMethodUrl",
             @"campaignDescriptionHistory":@"campaignDescriptionHistory",
             @"campaignDiscount":@"campaignDiscount",
             @"campaignProvider":@"campaignProvider"
            };
}

#pragma mark - Transformers

+ (NSValueTransformer*)dateCompletedOnJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer*)dateCancelledOnJSONTransformer {
    return [self numberToDateTransformer];
}

- (TripHistoryStatus)status {
    NSDictionary *knownStatuses = @{
                                     @"COMPLETED"       : @(TripCompleted),
                                     @"RIDER_CANCELLED" : @(TripCancelledByRider),
                                     @"DRIVER_CANCELLED": @(TripCancelledByDriver),
                                     @"ADMIN_CANCELLED" : @(TripCancelledByAdmin)
                                    };
    NSNumber *statusNumber = knownStatuses[self.rideStatus];
    if (statusNumber) {
        return (TripHistoryStatus)statusNumber.integerValue;
    } else {
        return TripStatusUnsupported;
    }
}

#pragma mark - Helper

- (BOOL)isCancelled {
    switch (self.status) {
        case TripStatusUnsupported:
        case TripCompleted:
            return NO;
        case TripCancelledByAdmin:
        case TripCancelledByRider:
        case TripCancelledByDriver:
            return YES;
    }
}

- (BOOL)hasCreditCardInfo{
    return !IS_EMPTY(self.cardNumber);
}

- (BOOL)hasCampaign {
    return self.campaignDiscount && self.campaignProvider;
}

- (NSString *)dateString {
    switch (self.status) {
        case TripCompleted:
            return [self.dateCompletedOn tripDateFormat];
            break;
        case TripCancelledByRider:
        case TripCancelledByDriver:
        case TripCancelledByAdmin:
            return [self.dateCancelledOn tripDateFormat];
        case TripStatusUnsupported:
            return @"";
    }
}

- (NSString *)statusString {
    switch (self.status) {
        case TripCompleted:
            return @"Completed";
        case TripCancelledByRider:
            return @"Rider Cancelled";
        case TripCancelledByDriver:
            return @"Driver Cancelled";
        case TripCancelledByAdmin:
            return @"Admin Cancelled";
        case TripStatusUnsupported:
            return @"";
    }
}

- (NSString *)carInformation {
    return (self.carBrand && self.carModel) ? [NSString stringWithFormat:@"%@ %@",self.carBrand,self.carModel] : @"";
}

@end

@implementation TripHistoryDataModel (ForDisplay)

- (NSString *)displayName {
    return self.driverNickName ?: self.driverFirstName;
}

- (NSString *)displayDiscount {
    return [NSString stringWithFormat:@"-$ %@", self.campaignDiscount];
}

- (NSString *)displayRideCost {
    return [NSString stringWithFormat:@"$ %@", self.rideTotalFare];
}

- (NSString *)displayTotalCharged {
    return [NSString stringWithFormat:@"$ %@", self.stripeCreditCharge];
}
@end
