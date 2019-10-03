//
//  DBRideDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DBRideDataModel.h"

@implementation DBRideDataModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}
+(NSDictionary *)JSONKeyPaths {
    return @{
//             @"id":@"id",
             @"createdDate":@"created_date",
//             @"updatedDate":@"updated_date",
//             @"baseFare":@"base_fare",
//             @"bookingFee":@"booking_fee",
             @"completedOn":@"completed_on",
             @"cancelledOn":@"cancelledOn",
//             @"distanceFare":@"distance_Fare",
//             @"distanceTravelled":@"distance_travelled",
             @"endLocationLat":@"end_location_lat",
             @"endLocationLong":@"end_location_long",
//             @"esimtatedFare":@"esimtated_fare",
//             @"minimumFare":@"minimum_fare",
//             @"ratePerMile":@"rate_per_mile",
//             @"ratePerMinute":@"rate_per_minute",
//             @"rating":@"rating",
             @"startLocationLat":@"start_location_lat",
             @"startLocationLong":@"start_location_long",
             @"startedOn":@"started_on",
//             @"status":@"status",
//             @"timeFare":@"time_fare",
//             @"totalFare":@"total_fare",
//             @"activeDriverId":@"active_driver_id",
//             @"riderId":@"rider_id",
             @"driverReachedOn":@"driver_reached_on",
//             @"driver_rating":@"driver_rating",
//             @"rider_rating":@"rider_rating",
//             @"distance_travelled_by_google":@"distance_travelled_by_google",
//             @"ride_map":@"ride_map",
//             @"ride_map_minimized":@"ride_map_minimized",
//             @"charge_id":@"charge_id",
//             @"pre_charge_id":@"pre_charge_id",
//             @"city_fee":@"city_fee",
//             @"sub_total":@"sub_total",
//             @"round_up_amount":@"round_up_amount",
             @"driverAcceptedOn":@"driver_accepted_on",
             @"startAddress":@"start_address",
             @"startZipCode":@"start_zip_code",
             @"endAddress":@"end_address",
             @"endZipCode":@"end_zip_code",
//             @"charity_id":@"charity_id",
//             @"driver_payment":@"driver_payment",
//             @"requested_car_category":@"requested_car_category",
//             @"free_credit_used":@"free_credit_used",
//             @"stripe_credit_charged":@"stripe_credit_charged",
//             @"cancellationFee":@"cancellation_fee",
//             @"driverSession_id":@"driver_session_id",
//             @"riderSession_id":@"rider_session_id",
//             @"surgeFactor":@"surge_factor",
//             @"surgeFare":@"surge_fare",
//             @"normalFare":@"normal_fare",
//             @"cancelledOn":@"cancelled_on",
//             @"tippedOn":@"tipped_on",
//             @"tip":@"tip",
//             @"esimtatedTimeArrive":@"esimtated_time_arrive",
//             @"raPayment":@"ra_payment",
//             @"paymentStatus":@"payment_status",
//             @"trackingShareToken":@"tracking_share_token",
//             @"requestedDriverType":@"requested_driver_type",
//             @"cityId":@"city_id",
//             @"startAreaId":@"start_area_id",
//             @"promocodeRedemption_id":@"promocode_redemption_id",
//             @"processingFee":@"processing_fee",
//             @"airportId":@"airport_id",
//             @"airportFee":@"airport_fee",
             @"comment":@"comment"
             };
}
+ (NSValueTransformer *)createdDateJSONTransformer {
    return [super stringToDateTransformerDB];
}
+ (NSValueTransformer *)completedOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
+ (NSValueTransformer *)cancelledOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
+ (NSValueTransformer *)startedOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
+ (NSValueTransformer *)driverReachedOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
+ (NSValueTransformer *)driverAcceptedOnJSONTransformer {
    return [super stringToDateTransformerDB];
}
/**
 *  @brief should be a complete ride
 */
-(BOOL)validate:(NSError *__autoreleasing *)error {
    return [super validate:error]
    && self.modelID           != nil
    && self.startAddress      != nil
    && self.startLocationLat  != nil
    && self.startLocationLong != nil
    && self.createdDate       != nil
    && self.driverAcceptedOn  != nil
    && self.driverReachedOn   != nil
    && (self.completedOn != nil || self.cancelledOn != nil);
}
// read only
-(NSInteger)secondsAccepted {
    return [self.driverAcceptedOn timeIntervalSinceDate:self.createdDate];
}
-(NSInteger)secondsReached {
    return [self.driverReachedOn timeIntervalSinceDate:self.createdDate];
}
-(NSInteger)secondsStartedTrip {
    return [self.startedOn timeIntervalSinceDate:self.createdDate];
}
-(NSInteger)secondsCompleted {
    return [self.completedOn timeIntervalSinceDate:self.createdDate];
}
-(NSInteger)secondsCancelled {
    return [self.cancelledOn timeIntervalSinceDate:self.createdDate];
}
@end
