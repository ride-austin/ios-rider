//
//  DBDriverLocationDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface DBDriverLocationDataModel : RABaseDataModel
//@property (nonatomic) NSNumber *distanceTravelled;
//@property (nonatomic) NSNumber *distanceTravelledByGoogle;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic) NSNumber *sequence;
@property (nonatomic) NSDate *trackedOn;
//@property (nonatomic) NSNumber *rideId;
@property (nonatomic) NSNumber *speed;
@property (nonatomic) NSNumber *heading;
@property (nonatomic) NSNumber *course;
//@property (nonatomic) NSNumber *originalLatitude;
//@property (nonatomic) NSNumber *originalLongitude;
@property (nonatomic) NSString *valid;
@end

/*
 originalLatitude originalLongitude were introduced as a part of snap-to-road location corrections
 server stored submitted location as original lat/lng and lat/lng itself. 
 Then snap-to-road was applied to lat/lng and these coordinates were updated
 
sample data:
    "id": 432828919,
    "distance_travelled": 46,
    "distance_travelled_by_google": 0,
    "latitude": 30.416902,
    "longitude": -97.750571,
    "sequence": 1493223443,
    "tracked_on": "2017-04-26 16:17:23",
    "ride_id": 2203566,
    "speed": 0,
    "heading": 289.535889,
    "course": 229.622726,
    "original_latitude": 30.416902,
    "original_longitude": -97.750571,
    "valid": "1"
*/
