//
//  RAUserDataModel.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAAvatarDataModel.h"
#import "RABaseDataModel.h"
#import <UIKit/UIKit.h>

@class RARiderDataModel;

@interface RAUserDataModel : RABaseDataModel

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong, nonnull) NSArray<RAAvatarDataModel*> *avatars;
@property (nonatomic, strong, nullable) NSString *email;
@property (nonatomic, strong, nullable) NSString *facebookID;
@property (nonatomic, strong, nullable) NSString *firstname;
@property (nonatomic, strong, nullable) NSString *middlename;
@property (nonatomic, strong, nullable) NSString *lastname;
@property (nonatomic, strong, nullable) NSString *fullName;
@property (nonatomic, strong, nullable) NSString *nickName;
@property (nonatomic, strong, nullable) NSString *gender;
@property (nonatomic, strong, nullable) NSString *phoneNumber;
@property (nonatomic, strong, nullable) NSURL *photoURL;
@property (nonatomic, strong, nullable) NSNumber *backgroundTracking;
@property (nonatomic, strong, nullable) NSString * referralCode;
@property (nonatomic, strong, nullable) NSString *password; //only used when registering
@property (nonatomic, strong, nullable) UIImage *picture; //only used when registering
- (NSString * _Nullable)displayName;

@end

@interface RAUserDataModel (Avatars)

- (RAAvatarDataModel * _Nullable)avatarOfType:(RAAvatarType)type;
- (BOOL)isDriver;
/**
 * @brief modelID is user_id in database table avatars
 */
- (NSNumber * _Nullable)riderID;
- (NSNumber * _Nullable)driverID;

@end

@interface RAUserDataModel (SecurePassword)

+ (NSString * _Nonnull)securePasswordWithEmail:(NSString * _Nonnull)email andPassword:(NSString * _Nonnull)password;

@end
