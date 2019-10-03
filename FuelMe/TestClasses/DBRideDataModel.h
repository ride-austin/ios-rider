//
//  DBRideDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface DBRideDataModel : RABaseDataModel
@property (nonatomic) NSDate *createdDate;
//@property (nonatomic) NSString *updatedDate;
//@property (nonatomic) NSString *baseFare;
//@property (nonatomic) NSString *bookingFee;
@property (nonatomic) NSDate *completedOn;
@property (nonatomic) NSDate *cancelledOn;
//@property (nonatomic) NSString *distanceFare;
//@property (nonatomic) NSString *distanceTravelled;
@property (nonatomic) NSNumber *endLocationLat;
@property (nonatomic) NSNumber *endLocationLong;
@property (nonatomic) NSString *comment;
//@property (nonatomic) NSString *esimtatedFare;
//@property (nonatomic) NSString *minimumFare;
//@property (nonatomic) NSString *ratePerMile;
//@property (nonatomic) NSString *ratePerMinute;
//@property (nonatomic) NSString *rating;
@property (nonatomic) NSNumber *startLocationLat;
@property (nonatomic) NSNumber *startLocationLong;
@property (nonatomic) NSDate *startedOn;
//@property (nonatomic) NSString *status;
//@property (nonatomic) NSString *timeFare;
//@property (nonatomic) NSString *totalFare;
//@property (nonatomic) NSString *activeDriverId;
//@property (nonatomic) NSString *riderId;
@property (nonatomic) NSDate *driverReachedOn;
//@property (nonatomic) NSString *driver_rating;
//@property (nonatomic) NSString *rider_rating;
//@property (nonatomic) NSString *distance_travelled_by_google;
//@property (nonatomic) NSString *ride_map;
//@property (nonatomic) NSString *ride_map_minimized;
//@property (nonatomic) NSString *charge_id;
//@property (nonatomic) NSString *pre_charge_id;
//@property (nonatomic) NSString *city_fee;
//@property (nonatomic) NSString *sub_total;
//@property (nonatomic) NSString *round_up_amount;
@property (nonatomic) NSDate *driverAcceptedOn;
@property (nonatomic) NSString *startAddress;
@property (nonatomic) NSString *startZipCode;
@property (nonatomic) NSString *endAddress;
@property (nonatomic) NSString *endZipCode;
//@property (nonatomic) NSString *charity_id;
//@property (nonatomic) NSString *driver_payment;
//@property (nonatomic) NSString *requested_car_category;
//@property (nonatomic) NSString *free_credit_used;
//@property (nonatomic) NSString *stripe_credit_charged;
//@property (nonatomic) NSString *cancellationFee;
//@property (nonatomic) NSString *driverSession_id;
//@property (nonatomic) NSString *riderSession_id;
//@property (nonatomic) NSString *surgeFactor;
//@property (nonatomic) NSString *surgeFare;
//@property (nonatomic) NSString *normalFare;
//@property (nonatomic) NSString *cancelledOn;
//@property (nonatomic) NSString *tippedOn;
//@property (nonatomic) NSString *tip;
//@property (nonatomic) NSString *esimtatedTimeArrive;
//@property (nonatomic) NSString *raPayment;
//@property (nonatomic) NSString *paymentStatus;
//@property (nonatomic) NSString *trackingShareToken;
//@property (nonatomic) NSString *requestedDriverType;
//@property (nonatomic) NSString *cityId;
//@property (nonatomic) NSString *startAreaId;
//@property (nonatomic) NSString *promocodeRedemption_id;
//@property (nonatomic) NSString *processingFee;
//@property (nonatomic) NSString *airportId;
//@property (nonatomic) NSNumber *airportFee;
-(NSInteger)secondsAccepted;
-(NSInteger)secondsReached;
-(NSInteger)secondsStartedTrip;
-(NSInteger)secondsCompleted;
-(NSInteger)secondsCancelled;
@end
/*
SAMPLE DATA:
{
    "id": 2203566,
    "created_date": "2017-04-26 16:15:03",
    "updated_date": "2017-04-26 16:25:09",
    "base_fare": 1.5,
    "booking_fee": 2,
    "completed_on": "2017-04-26 16:24:46",
    "distance_Fare": 6.13,
    "distance_travelled": 9963,
    "end_location_lat": 30.347151,
    "end_location_long": -97.714175,
    "esimtated_fare": 12.67,
    "minimum_fare": 4,
    "rate_per_mile": 0.99,
    "rate_per_minute": 0.25,
    "rating": null,
    "start_location_lat": 30.4171743,
    "start_location_long": -97.7502108,
    "started_on": "2017-04-26 16:17:22",
    "status": "COMPLETED",
    "time_fare": 1.85,
    "total_fare": 11.59,
    "active_driver_id": 1998642,
    "rider_id": 392790,
    "driver_reached_on": "2017-04-26 16:15:37",
    "driver_rating": null,
    "rider_rating": 5,
    "distance_travelled_by_google": null,
    "ride_map": "ride-maps/77813e01-9578-4631-843e-0bbe2089ac91.png",
    "ride_map_minimized": "ride-maps/fb22c468-95f8-4c5d-ab9e-fe137bcf430f.png",
    "charge_id": null,
    "pre_charge_id": "ch_1ACsnBF1zTsipGiNlfjPK31x",
    "city_fee": 0.11,
    "sub_total": 9.48,
    "round_up_amount": 0,
    "driver_accepted_on": "2017-04-26 16:15:14",
    "start_address": "11624 Jollyville Road",
    "end_address": "7866 N Lamar Blvd, Austin",
    "start_zip_code": "78759",
    "end_zip_code": "78752",
    "charity_id": null,
    "driver_payment": 9.48,
    "requested_car_category": "REGULAR",
    "free_credit_used": 0,
    "stripe_credit_charged": null,
    "cancellation_fee": null,
    "driver_session_id": 2097723,
    "rider_session_id": 2137556,
    "surge_factor": 1,
    "surge_fare": 0,
    "normal_fare": 9.48,
    "cancelled_on": null,
    "tipped_on": null,
    "tip": null,
    "esimtated_time_arrive": 190,
    "ra_payment": 0,
    "payment_status": null,
    "tracking_share_token": null,
    "requested_driver_type": null,
    "city_id": 1,
    "start_area_id": 1442,
    "promocode_redemption_id": null,
    "processing_fee": 1,
    "airport_id": null,
    "airport_fee": 0
}
*/
