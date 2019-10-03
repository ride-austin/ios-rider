//
//  RAUserDataModel.m
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAUserDataModel.h"

#import "AppConfig.h"

@implementation RAUserDataModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return  [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RAUserDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"active": @"active",
             @"enabled": @"enabled",
             @"email": @"email",
             @"facebookID": @"facebookId",
             @"firstname": @"firstname",
             @"middlename": @"middlename",
             @"lastname": @"lastname",
             @"fullName": @"fullName",
             @"nickName": @"nickName",
             @"gender" : @"gender",
             @"phoneNumber": @"phoneNumber",
             @"photoURL": @"photoUrl",
             @"avatars": @"avatars",
             @"backgroundTracking": @"backgroundTracking",
             @"referralCode" : @"referralCode"
            };
}


#pragma mark - JSON Transformer

+ (NSValueTransformer *)avatarsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RAAvatarDataModel.class];
}

#pragma mark - Model Protocol

- (NSArray<NSString *> *)excludeProperties {
    return @[@"active",@"enabled"];
}

- (BOOL)performCustomUpdateWithModel:(RABaseDataModel *)model {
    BOOL changed = NO;
    
    RAUserDataModel *userModel = (RAUserDataModel*)model;
    
    BOOL temp = [self updateBoolProperty:self.active withOtherBoolProperty:userModel.active];
    if (temp) {
        self.active = userModel.active;
    }
    changed = changed || temp;
    
    temp = [self updateBoolProperty:self.enabled withOtherBoolProperty:userModel.enabled];
    if (temp) {
        self.enabled = userModel.enabled;
    }
    changed = changed || temp;
    
    return changed;
}

- (NSString *)displayName {
    return self.nickName ?: self.firstname;
}

@end

#pragma mark - Avatars

@implementation RAUserDataModel (Avatars)

- (RAAvatarDataModel *)avatarOfType:(RAAvatarType)type {
    RAAvatarDataModel *avatar = nil;
    
    NSUInteger i = 0;
    while (!avatar && i<self.avatars.count) {
        RAAvatarDataModel *av = self.avatars[i];
        
        if (av.type == type) {
            avatar = av;
        }
        
        i++;
    }
    
    return avatar;
}

- (BOOL)isDriver {
    return self.driverID != nil;
}

- (NSNumber *)riderID {
    RAAvatarDataModel *rider = [self avatarOfType:RAAvatarRider];
    return rider.modelID;
}

- (NSNumber *)driverID {
    RAAvatarDataModel *driver = [self avatarOfType:RAAvatarDriver];
    return driver.modelID;
}

@end

#pragma mark - Secure Password

#import "NSString+Utils.h"

@implementation RAUserDataModel (SecurePassword)

+ (NSString *)securePasswordWithEmail:(NSString *)email andPassword:(NSString *)password {
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@", [email lowercaseString], [AppConfig md5PasswordSalt], password];
    return [pwd md5];
}

@end
