//
//  MockRideResponseModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 4/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
@class DBRideDataModel;
@class DBDriverLocationDataModel;
typedef NS_ENUM(NSUInteger, MockRideStatus) {
    MockRideStatusRequested = 0,
    MockRideStatusNotAvailableDriver = 1,
    MockRideStatusDriverAssigned = 2,
    MockRideStatusDriverReached = 3,
    MockRideStatusActive = 4,
    MockRideStatusCompleted = 5,
    MockRideStatusCancelledByRider = 6,
    MockRideStatusCancelledByDriver = 7
};
@interface MockRideResponseModel : RABaseDataModel

+(void)resetInjections;
+ (NSDictionary *)dictionaryWithRide:(DBRideDataModel *)ride
                              status:(MockRideStatus)status
                            location:(DBDriverLocationDataModel *)location
                           injections:(NSArray<NSDictionary *> *)injections;
@end
/*
{
    "activeDriver" :     {
        "availableCarCategoriesBitmask" : 1,
        "availableDriverTypesBitmask" : 0,
        "carCategories" :         [
                                   "REGULAR"
                                   ],
        "cityId" : 1,
        "directDistanceToRider" : "14214936.05181779",
        "driver" :         {
            "activationStatus" : "ACTIVE",
            "active" : 1,
            "agreedToLegalTerms" : 1,
            "agreementDate" : "2016-06-13 11:38:55",
            "cars" :             [
                                  {
                                      "carCategories" :                     [
                                                                             "REGULAR"
                                                                             ],
                                      "color" : "Blue",
                                      "id" : 12,
                                      "inspectionStatus" : "NOT_INSPECTED",
                                      "inspectionSticker" : 0,
                                      "insurancePictureUrl" : "https://s3.amazonaws.com/media-stage.rideaustin.com/driver-insurances/2c063534-ff53-4b1a-a773-21cdde58def9.png?AWSAccessKeyId:AKIAJRZKPEUYYX2JFKEA&Expires:1493217552&Signature:hSrNgl46fLduQZA%2Fu9yYHDuIe2U%3D",
                                      "license" : GC96ZK,
                                      "make" : Lexus,
                                      "model" : "LC 500",
                                      "removed" : 0,
                                      "selected" : 1,
                                      "uuid" : 12,
                                      "year" : 2018,
                                  }
                                  ],
            "checkrReports" :             [
            ],
            "checkrStatus" : "PENDING",
            "cityApprovalStatus" : "NOT_PROVIDED",
            "cityId" : 1,
            "email" : "aghishi@yahoo.es",
            "enabledRequestTypes" :             [
            ],
            "facebookId" : 1747128938835717,
            "fingerprintCleared" : 0,
            "firstname" : Kitos,
            "fullName" : "Kitos Test",
            "gender" : "UNKNOWN",
            "grantedDriverTypes" :             [
            ],
            "id" : 52,
            "lastname" : Test,
            "licenseExpiryDate" : "2019-03-22",
            "licenseNumber" : 12345678,
            "licensePictureUrl" : "https://s3.amazonaws.com/media-stage.rideaustin.com/driver-licenses/59b0005f-56de-4d9f-b108-e3d20235fd38.png?AWSAccessKeyId:AKIAJRZKPEUYYX2JFKEA&Expires:1493217552&Signature:dfAx7JHL6sTs%2FqT%2BgosNKhDEKO8%3D",
            "licenseState" : TX,
            "onboardingPendingSince" : 1493217372635,
            "onboardingStatus" : "ACTIVE",
            "payoneerId" : 0,
            "payoneerStatus" : Active,
            "phoneNumber" : "+48784062443",
            "photoUrl" : "https://graph.facebook.com/1747128938835717/picture?type:large",
            "rating" : 5,
            "ssn" : "123-22-1234",
            "type" : "DRIVER",
            "user" :             {
                "address" :                 {
                    "address" : "10600 Zeus Cove Austin, TX 78759, US",
                },
                "avatars" :                 [
                ],
                "dateOfBirth" : "1995-08-30",
                "email" : "aghishi@yahoo.es",
                "enabled" : 1,
                "facebookId" : 1747128938835717,
                "firstname" : "Kitos",
                "fullName" : "Kitos Test",
                "gender" : "UNKNOWN",
                "id" : 22,
                "lastname" : "Test",
                "phoneNumber" : "+48784062443",
                "photoUrl" : "https://graph.facebook.com/1747128938835717/picture?type:large",
                "uuid" : 22,
            },
            "uuid" : 52,
        },
        "id" : 27869,
        "latitude" : "39.991356",
        "longitude" : "-6.539596",
        "selectedCar" :         {
            "carCategories" :             [
                                           "REGULAR"
                                           ],
            "color" : "Blue",
            "id" : 12,
            "inspectionStatus" : "NOT_INSPECTED",
            "inspectionSticker" : 0,
            "insurancePictureUrl" : "https://s3.amazonaws.com/media-stage.rideaustin.com/driver-insurances/2c063534-ff53-4b1a-a773-21cdde58def9.png?AWSAccessKeyId:AKIAJRZKPEUYYX2JFKEA&Expires:1493217552&Signature:hSrNgl46fLduQZA%2Fu9yYHDuIe2U%3D",
            "license" : "GC96ZK",
            "make" : "Lexus",
            "model" : "LC 500",
            "removed" : 0,
            "selected" : 1,
            "uuid" : 12,
            "year" : 2018,
        },
        "status" : "RIDING",
        "uuid" : 27869,
    },
    "cityId" : 1,
    "createdDate" : 1493217232000,
    "driverAcceptedOn" : 1493217248000,
    "end" :     {
    },
    "estimatedTimeArrive" : 147,
    "id" : 1225065,
    "raPayment" : "0.00",
    "requestedCarType" :     {
        "active" : 1,
        "baseFare" : "1.50",
        "bookingFee" : "2.00",
        "cancellationFee" : "4.00",
        "carCategory" : "REGULAR",
        "cityId" : 1,
        "description" : "Standard Car",
        "iconUrl" : "https://media.rideaustin.com/icon/regular.png",
        "maxPersons" : 4,
        "minimumFare" : "5.00",
        "order" : 1,
        "processingFee" : "1.00",
        "processingFeeRate" : 1,
        "processingFeeText" : "$1.00 Processing fee",
        "raFeeFactor" : 0,
        "ratePerMile" : "0.99",
        "ratePerMinute" : "0.25",
        "title" : "STANDARD",
        "tncFeeRate" : 1,
    },
    "rideCost" : "0.00",
    "rider" :     {
        "active" : 1,
        "charity" :     {
            "cityBitmask": 2,
            "id" : 51,
            "imageUrl" : "https://media.rideaustin.com/images/roundup/blue-santa@2x.png",
            "name" : "Blue Santa Houston",
            "order" : 1
        },
        "cityId" : 1,
        "email" : "user1@gmail.com",
        "firstname" : "Jose",
        "fullName" : "Jose Abreu",
        "gender" : "UNKNOWN",
        "id" : 1823,
        "lastLoginDate" : 1493091484000,
        "lastname" : "Abreu",
        "phoneNumber" : "+18093212132",
        "rating" : 5,
        "stripeId" : "cus_AXMCEJ2Lr0D0gp",
        "type" : "RIDER",
        "user" :     {
            "active" : 1,
            "avatars" :  [
                          {
                              "active" : 1,
                              "id" : 1823,
                              "type" : "RIDER"
                          }
                          ],
            "email" : "user1@gmail.com",
            "enabled" : 1,
            "firstname" : "Jose",
            "fullName" : "Jose Abreu",
            "gender" : "UNKNOWN",
            "id" : 1443,
            "lastname" : "Abreu",
            "phoneNumber" : "+18093212132",
            "photoUrl" : "http://media-stage.rideaustin.com/user-photos/91be7cb1-c815-4ca4-b68a-4bfcc1cf9274.png",
            "uuid" : 1443,
        },
        "uuid": 1823
    },
    "start" :     {
        "address" : "800 Rio Grande Street, Austin, Texas",
        "zipCode" : "78701",
    },
    "startAddress" : "800 Rio Grande Street, Austin, Texas",
    "startAreaId" : 1899,
    "startLocationLat" : 30.272073,
    "startLocationLong" : -97.749093,
    "status" : "ACTIVE",
    "surgeFactor" : 1,
    "totalCharge" : "0.00",
    "totalFare" : "0.00",
    "updatedDate" : 1493218017265,
    "uuid" : 1010
}
*/
