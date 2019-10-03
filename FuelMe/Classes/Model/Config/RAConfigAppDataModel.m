//
//  RAConfigApp.m
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAConfigAppDataModel.h"
#import "RAMacros.h"
#import "NSString+CompareToVersion.h"
#import "NSString+Utils.h"

@interface RAConfigAppDataModel ()

@property (nonatomic) BOOL shouldUpgrade;
@property (nonatomic) BOOL mustUpgrade;

@end

@interface RAConfigAppDataModel (Private)

- (BOOL)getUpgradeStatus;

@end

@implementation RAConfigAppDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:
                @{
                  @"avatar":@"avatarType",
                  @"platform":@"platformType",
                  @"version":@"version",
                  @"mandatoryUpgrade":@"mandatoryUpgrade",
                  @"userAgentHeader":@"userAgentHeader",
                  @"upgradeURL":@"downloadUrl"
                  }
            ];
}

+ (NSValueTransformer *)mandatoryUpgradeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self) {
        self.shouldUpgrade = [self getUpgradeStatus];
        self.mustUpgrade = self.shouldUpgrade && self.isMandatory;
        DBLog(@"should upgrade: %@ - mandatory: %@",self.shouldUpgrade?@"Yes":@"No", self.isMandatory?@"Yes":@"No");
        
        if (!self.upgradeURL) {
            self.upgradeURL = [NSURL URLWithString:kiOSRiderDownloadURL];
        }
    }
    
    return self;
}

@end

#pragma mark - Private

//version format pattern AnyInt.AnyInt.AnyInt
static NSString *const kVersionPattern = @"[0-9]+\\.[0-9]+\\.[0-9]+";

@implementation RAConfigAppDataModel (Private)

- (BOOL)getUpgradeStatus {
    NSString *appVersion = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"] matchWithPattern:kVersionPattern];
    NSString *serverVersion = [self.version matchWithPattern:kVersionPattern];
    DBLog(@"app version: %@ - server version: %@",appVersion, serverVersion);
    return [appVersion isOlderThanVersion:serverVersion];
}

@end
