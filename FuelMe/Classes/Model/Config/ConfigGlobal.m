//
//  ConfigGlobal.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigGlobal.h"

@interface ConfigGlobal()

@property (nonatomic) NSArray<RACoordinate *> *cityBoundaryPolygon;
@property (nonatomic) NSArray<RADriverTypeDataModel*> *driverTypes;

@end

@implementation ConfigGlobal

- (instancetype)init {
    if (self = [super init]) {
        _ridesConfig    = [ConfigRides new];
        _commonMessages = [ConfigMessagesCommon new];
        _genderSelection = [ConfigGenderSelection new];
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"accessibleDriver"       : @"accessibility",
      @"cancellationFeedback"   : @"cancellationFeedback",
      @"commonMessages"         : @"commonMessages",
      @"currentCity"            : @"currentCity",
      @"directConnectPhone"     : @"directConnectPhone",
      @"ridesConfig"            : @"rides",
      @"genderSelection"        : @"genderSelection",
      @"generalInfo"            : @"generalInformation",
      @"geocoding"              : @"geocodingConfiguration",
      @"isPhoneMaskingEnabled"  : @"smsMaskingEnabled",
      @"liveLocation"           : @"riderLiveLocation",
      @"referRider"             : @"riderReferFriend",
      @"supportedCities"        : @"supportedCities",
      @"tipping"                : @"tipping",
      @"unpaidBalance"          : @"unpaidBalance",
      @"ut"                     : @"UT",
      @"carTypes"               : @"carTypes",
      @"driverTypes"            : @"driverTypes",
      @"campaignProviders"      : @"campaignProviders",
      @"promoCredits"           : @"promoCredits",
      @"configDirectConnect"    : @"directConnect"
      };
}

#pragma mark - Value Transformers

+ (NSValueTransformer *)accessibleDriverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigAccessibleDriver class]];
}

+ (NSValueTransformer *)cancellationFeedbackJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ConfigCancellationFeedback.class];
}

+ (NSValueTransformer *)commonMessagesJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigMessagesCommon class]];
}

+ (NSValueTransformer *)currentCityJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACity class]];
}

+ (NSValueTransformer *)ridesConfigJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigRides class]];
}

+ (NSValueTransformer *)genderSelectionJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ConfigGenderSelection.class];
}

+ (NSValueTransformer *)generalInfoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RAGeneralInfo class]];
}

+ (NSValueTransformer *)geocodingJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigGeoCoding class]];
}

+ (NSValueTransformer *)liveLocationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigLiveLocation class]];
}

+ (NSValueTransformer *)referRiderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigReferRider class]];
}

+ (NSValueTransformer *)supportedCitiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACity class]];
}

+ (NSValueTransformer *)tippingJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigTipping class]];
}

+ (NSValueTransformer *)unpaidBalanceJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigUnpaidBalance class]];
}

+ (NSValueTransformer *)utJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigUT class]];
}

+ (NSValueTransformer *)campaignProvidersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RACampaignProvider.class];
}

+ (NSValueTransformer *)carTypesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACarCategoryDataModel class]];
}

+ (NSValueTransformer *)driverTypesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RADriverTypeDataModel.class];
}

+ (NSValueTransformer *)promoCreditsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigPromoCredits class]];
}

+ (NSValueTransformer *)configDirectConnectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigDirectConnect class]];
}

- (RADriverTypeDataModel *)womanOnly {
    for (RADriverTypeDataModel *driverType in self.driverTypes) {
        if ([driverType.name isEqualToString:@"WOMEN_ONLY"]) {
            return driverType;
        }
    }
    return nil;
}

- (RADriverTypeDataModel *)fingerprintedDrivers {
    for (RADriverTypeDataModel *driverType in self.driverTypes) {
        if ([driverType.name isEqualToString:@"FINGERPRINTED"]) {
            return driverType;
        }
    }
    return nil;
}

@end

@implementation ConfigGlobal (PrefetchURLs)

- (NSArray<NSURL *> *)urls {
    NSMutableArray *mArray = [NSMutableArray new];
    if (self.generalInfo.urls) {
        [mArray addObjectsFromArray:self.generalInfo.urls];
    }
    
    if ([self.carTypes valueForKey:@"sliderIconUrl"]) {
        [mArray addObjectsFromArray:[self.carTypes valueForKey:@"sliderIconUrl"]];
    }
    
    if ([self.carTypes valueForKey:@"mapIconUrl"]) {
        [mArray addObjectsFromArray:[self.carTypes valueForKey:@"mapIconUrl"]];
    }
    
    if ([self.carTypes valueForKey:@"plainIconUrl"]) {
        [mArray addObjectsFromArray:[self.carTypes valueForKey:@"plainIconUrl"]];
    }
    
    return mArray;
}

@end
