//
//  RASurgeAreaDataModel.h
//  Ride
//
//  Created by Kitos on 16/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

#import <GoogleMaps/GoogleMaps.h>

/*
{
    automated = 0;
    bottomRightCornerLat = "30.282788";
    bottomRightCornerLng = "-97.73772200000001";
    carCategories =             (
                                 REGULAR,
                                 LUXURY,
                                 SUV,
                                 PREMIUM
                                 );
    centerPointLat = "30.2632";
    centerPointLng = "-97.71469999999999";
    createdDate = 1471617300000;
    csvGeometry = "-97.736177,30.252024 -97.737722,30.258622 -97.730169,30.278341 -97.701931,30.282788 -97.701759,30.281454 -97.703390,30.281157 -97.698412,30.274783 -97.693005,30.258178 -97.690172,30.246167 -97.698412,30.246018 -97.700987,30.250319 -97.717981,30.251357 -97.720985,30.248391 -97.725105,30.247279 -97.736177,30.251950";
    id = 17;
    mandatory = 0;
    name = 78702;
    numberOfAcceptedRides = 0;
    numberOfAvailableCars = 0;
    numberOfCars = 0;
    numberOfEyeballs = 0;
    numberOfRequestedRides = 0;
    recommendedSurgeFactor = 1;
    surgeFactor = 3;
    topLeftCornerLat = "30.246018";
    topLeftCornerLng = "-97.690172";
    updatedDate = 1481889900000;
    zipCode = 78702;
}
*/

@interface RASurgeAreaDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) NSDictionary<NSString *,NSNumber *> *carCategoriesFactors;

- (GMSPath *)boundary;
- (BOOL)boundaryContainsLocation:(CLLocation*)location;

@end
