//
//  ConfigGlobal.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigAccessibleDriver.h"
#import "ConfigCancellationFeedback.h"
#import "ConfigDirectConnect.h"
#import "ConfigGenderSelection.h"
#import "ConfigGeoCoding.h"
#import "ConfigLiveLocation.h"
#import "ConfigMessagesCommon.h"
#import "ConfigPromoCredits.h"
#import "ConfigReferRider.h"
#import "ConfigRides.h"
#import "ConfigTipping.h"
#import "ConfigUT.h"
#import "ConfigUnpaidBalance.h"
#import "RACampaignProvider.h"
#import "RACarCategoryDataModel.h"
#import "RACity.h"
#import "RADriverTypeDataModel.h"
#import "RAGeneralInfo.h"
#import "RAPickupHint.h"

#import <Mantle/Mantle.h>

@interface ConfigGlobal : MTLModel <MTLJSONSerializing>

@property (nonatomic, nullable) ConfigAccessibleDriver *accessibleDriver;
@property (nonatomic, nullable) ConfigCancellationFeedback *cancellationFeedback;
@property (nonatomic, nullable, readonly) ConfigMessagesCommon *commonMessages;
@property (nonatomic, nullable) RACity *currentCity;
@property (nonatomic, nullable) NSString *directConnectPhone;
@property (nonatomic, nullable) ConfigRides *ridesConfig;
@property (nonatomic, nullable, readonly) ConfigGenderSelection *genderSelection;
@property (nonatomic, nullable) RAGeneralInfo *generalInfo;
@property (nonatomic, nullable) ConfigGeoCoding *geocoding;
@property (nonatomic) BOOL isPhoneMaskingEnabled;
@property (nonatomic, nullable) ConfigReferRider *referRider;
@property (nonatomic, nullable) ConfigLiveLocation *liveLocation;
@property (nonatomic, nullable) NSArray <RACity *> *supportedCities;
@property (nonatomic, nullable) ConfigTipping *tipping;
@property (nonatomic, nullable, readonly) ConfigUnpaidBalance *unpaidBalance;
@property (nonatomic, nullable) ConfigUT *ut;
@property (nonatomic, nullable) NSArray<RACarCategoryDataModel*> *carTypes;
@property (nonatomic, nullable, readonly) NSArray<RACampaignProvider *>*campaignProviders;
@property (nonatomic, nullable) ConfigPromoCredits *promoCredits;
@property (nonatomic, nullable) ConfigDirectConnect *configDirectConnect;

- (RADriverTypeDataModel * _Nullable)womanOnly;
- (RADriverTypeDataModel * _Nullable)fingerprintedDrivers;

@end

@interface ConfigGlobal (PrefetchURLs)

- (NSArray<NSURL *> * _Nonnull)urls;

@end
