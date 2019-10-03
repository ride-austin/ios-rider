//
//  RAGeneralInfo.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RAGeneralInfo : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *appName;
@property (nonatomic) NSString *appNamePipe;
@property (nonatomic) NSURL *appstoreLink;
@property (nonatomic) NSString *companyDomain;
@property (nonatomic) NSURL *companyWebsite;
@property (nonatomic) NSURL *facebookUrl;
@property (nonatomic) NSURL *facebookUrlSchemeiOS;
@property (nonatomic) NSURL *iconURL;
@property (nonatomic) NSURL *legalRiderURL;
@property (nonatomic) NSURL *privacyURL;
@property (nonatomic) NSURL *logoURL;
@property (nonatomic) NSURL *splashURL;
@property (nonatomic) NSString *supportEmail;

@end

@interface RAGeneralInfo (PrefetchURLs)

- (NSArray<NSURL *> *)urls;

@end
