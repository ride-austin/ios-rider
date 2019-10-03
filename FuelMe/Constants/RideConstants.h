//
//  RideConstants.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/23/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#ifndef RideConstants_h
#define RideConstants_h
//
//  Received when user email is received
//
extern NSString *const kDidSigninNotification;
extern NSString *const kDidSignoutNotification;
extern NSString *const kCompanyNamesKey;

extern NSString * const kFacebookSignin;

// Promo Types
extern NSString *const PromoCodeTypeFixedPrice;
extern NSString *const PromoCodeTypeFixedDelivery;
extern NSString *const PromoCodeTypeMoneyOff;
extern NSString *const PromoCodeTypeCredit;

// Rest endpoints
extern NSString *const UserResourcePath;
extern NSString *const kDriverPhotoPath;
extern NSString *const kDriverCarPhotoPath;

// Errors
extern NSString *const kErrorAppVersionDomain;
extern NSString *const kErrorAppVersionUpgradeURLKey;
extern NSString *const kErrorLocationNotFound;

typedef enum {
    FrontPhoto = 0,
    BackPhoto = 1,
    InsidePhoto = 2,
    TrunkPhoto = 3
} CarPhotoType;

typedef NS_ENUM(NSUInteger, PaymentMethod) {
    PaymentMethodUnspecified = 0,
    PaymentMethodPrimaryCreditCard = 1,
    PaymentMethodBevoBucks = 2,
    PaymentMethodApplePay = 3
};


/**
 LocationViewController UI States
 */
typedef NS_ENUM(NSInteger, RALocationViewState){
    RALocationViewStateClear = 0,
    RALocationViewStateInitial,
    RALocationViewStatePrepared,
    RALocationViewStateRequesting,
    RALocationViewStateRideAssigned,
    RALocationViewStateWaitingDriver,
    RALocationViewStateDriverReached,
    RALocationViewStateTripStarted,
    RALocationViewStateTripCanceled,
    RALocationViewStateRating
};

typedef  NS_ENUM(NSUInteger, RAPickerAddressFieldType){
    RAPickerAddressPickupFieldType = 0,
    RAPickerAddressDestinationFieldType = 1
};
#endif
