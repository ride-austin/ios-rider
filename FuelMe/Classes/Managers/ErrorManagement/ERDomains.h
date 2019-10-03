//
//  ERDomains.h
//  Ride
//
//  Created by Theodore Gonzalez on 9/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#ifndef ERDomains_h
#define ERDomains_h
#endif /* ERDomains_h */
/**
 *  @brief GET, POST, PUT, DELETE for request types
 *
 *  FB, GOOGLE, APPLE for third party APIs
 *
 *  UI for unexpected UI issue
 *
 *  WATCH for observing fixes for issues that are reported but cannot be easily reproduced
 */
typedef NS_ENUM(NSInteger, ERDomain) {
    UnspecifiedDomain                   = 0,
    
    GETCharities,
    GETRidersRiderID,
    GETUser                             = -100,
    GETPromoCode                        = -101,
    GETDiscount                         = -102, //Not used
    GETCurrentRide                      = -103,
    GETActiveDrivers                    = -104,
    GETRideByID                         = -107,
    GETVersion                          = -113,
    GETVersionInvalid                   = -126,
    GETSplitList                        = -127,
    GETSplitListInvalidData             = -128,
    GETRideEstimate                     = -129,
    GETRideMap                          = -130,
    GETRideListForStatus                = -131,
    GETRideListForStatusCharged         = -132,
    GETSurgeAreas                       = -133,
    GETTipSettings                      = -134,
    GETDriversCarTypes                  = -135,
    
    GETCards                            = -138,
    GETRidersPayments                    = -139,
    GETDriverTypes                      = -140,
    GETIPAddress                        = -141,
    GETCurrentCityConfiguration         = -142,
    GETCityDetail                       = -143,
    GETGlobalConfigurationInvalidData   = -144,
    GETGlobalConfiguration              = -145,
    GETDriverTerms                      = -146,
    GETShareTokenLiveETA                = -147,
    GETRideSpecialFees                  = -148,
    
    POSTSignupDriver                    = -200,
    POSTLogin                           = -203,
    POSTSignupAvailability              = -204,
    
    POSTCreateUser                      = -202,
    POSTFacebookRegister                = -209,
    POSTFacebookLogin                   = -212,
    POSTRequestRide                     = -210,
    POSTSupport                         = -211,
    POSTPhotosProfile                   = -213,
    POSTDriversCarPhoto                 = -214,
    POSTSplitFareRequest                = -215,
    POSTSplitFareRespond                = -216,
    POSTPromo                           = -217,
    POSTPhoneVerificationRequest        = -218,
    POSTPhoneVerificationSubmit         = -219,
    POSTCallRequest                     = -220,
    POSTMaskSMS                         = -221,
    POSTDriversDocuments                = -222,
    
    PUTRateRide                         = -301,
    PUTSaveProfile                      = -303,
    PUTSetPrimaryCard                   = -304,
    PUTUpdateDestination                = -305,
    PUTRidersRiderID                    = -306,
    PUTUpdateComments                   = -307,
    
    DELETECard                          = -401,
    DELETERideByID                      = -402,
    DELETESplitFareByID                 = -403,

    GOOGLEReverseGeocode                = -500,
//  GOOGLEZipBoundaries                 = -501,
    GOOGLEGetRoute                      = -502,
//  GOOGLEAutoComplete                  = -503,
    APPLEReverseGeoCode                 = -550,

    FBLogin                             = -600,
    FBGraph                             = -601,

    TryLogin                            = -602,
    URLInvalidImage                     = -605,
    
    STRIPECreateToken                   = -701,
    SINCHVerify                         = -800,

    WATCHCacheWithoutEmail              = -700,
    WATCHNullRideID                     = -999,
    WATCHUnknownRideStatus              = -6700,
    WATCHNullCurrentLocation            = -4562,
    WATCHNullStartAddress               = -4563,
    WATCHNullEndAddress                 = -4564,
    WATCHNullRideRequestCarCategory     = -6328
};
