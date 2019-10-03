//
//  RAGeneralInfo.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAGeneralInfo.h"

@implementation RAGeneralInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"appName"                :@"applicationName",
      @"appNamePipe"            :@"applicationNamePipe",
      @"appstoreLink"           :@"appstoreLink",
      @"companyDomain"          :@"companyDomain",
      @"companyWebsite"         :@"companyWebsite",
      @"facebookUrl"            :@"facebookUrl",
      @"facebookUrlSchemeiOS"   :@"facebookUrlSchemeiOS",
      @"iconURL"                :@"iconUrl",
      @"legalRiderURL"          :@"legalRider",
      @"privacyURL"             :@"privacy",
      @"logoURL"                :@"logoUrl",
      @"splashURL"              :@"splashUrl",
      @"supportEmail"           :@"supportEmail"
      };
}

+ (NSValueTransformer *)appstoreLinkJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)companyWebsiteJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)facebookURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)facebookUrlSchemeiOSJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)iconURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)legalRiderURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)privacyURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)logoURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)splashURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appName        = @"Ride Austin";
        self.appstoreLink   = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1116489847"];
        self.companyDomain  = @"RideAustin.com";
        self.companyWebsite = [NSURL URLWithString:@"http://www.rideaustin.com"];
        self.facebookUrl    = [NSURL URLWithString:@"https://www.facebook.com/werideaustin"];
        self.legalRiderURL  = [NSURL URLWithString:@"http://www.rideaustin.com/legal/userterms"];
        self.privacyURL     = [NSURL URLWithString:@"http://www.rideaustin.com/privacy"];
        self.supportEmail   = @"support@rideaustin.com";
    }
    return self;
}

/***
 * sample data
 
generalInformation =     {
    applicationName = "Ride Austin";
    applicationNamePipe = "Ride|Austin";
    appstoreLink = "itms-apps://itunes.apple.com/app/id1116489847";
    companyDomain = "rideaustin.com";
    companyWebsite = "http://www.rideaustin.com";
    facebookUrl = "https://www.facebook.com/werideaustin";
    facebookUrlSchemeiOS = "fb://page/241278152906970";
    iconUrl = "https://media.rideaustin.com/images/Ride_180-1.png";
    legal = "http://www.rideaustin.com/legal/userterms/";
    logoUrl = "https://media.rideaustin.com/images/logoRideAustin@3x.jpg";
    playStoreLink = "market://details?id=com.rideaustin.android";
    playStoreWeb = "https://play.google.com/store/apps/details?id=com.rideaustin.android";
    splashUrl = "https://media.rideaustin.com/images/photoAustin@3x.png";
    supportEmail = "support@rideaustin.com";
}
 */
@end

@implementation RAGeneralInfo (PrefetchURLs)

- (NSArray<NSURL *> *)urls {
    NSMutableArray *mArray = [NSMutableArray new];
    if (self.iconURL) {
        [mArray addObject:self.iconURL];
    }
    if (self.logoURL) {
        [mArray addObject:self.logoURL];
    }
    if (self.splashURL) {
        [mArray addObject:self.splashURL];
    }
    return mArray;
}

@end
