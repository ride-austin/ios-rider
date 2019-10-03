//
//  RASessionManager.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAUserDataModel.h"
#import "RARiderDataModel.h"
#import "RASessionDataModel.h"

@interface RASessionManager : NSObject

@property (nonatomic, readonly) BOOL needsToRegisterPhone;

@property (nonatomic, readonly, nullable) RAUserDataModel *currentUser;
@property (nonatomic, readonly, nullable) RARiderDataModel *currentRider;
@property (nonatomic, readonly, getter=isSignedIn) BOOL logged;

@property (nonatomic, getter=isRegistering) BOOL registering; //use for external purposes, not managed by sessionManager.

+(RASessionManager * _Nonnull) sharedManager;
+(BOOL)hasAuthToken;
-(BOOL)isLoggedWithFacebok;
-(void)saveContext;
-(void)clearCurrentSession;
-(void)clearHeader;

@end

typedef void(^RALoginCompletionBlock)(RAUserDataModel * _Nullable user, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN
@interface RASessionManager (SignIn)

-(void)loginWithUsername:(NSString*)username password:(NSString*)password andCompletion:(RALoginCompletionBlock) handler;
-(void)loginWithFacebookFromViewController:(UIViewController*)viewController andCompletion:(RALoginCompletionBlock)handler;

@end

@interface RASessionManager (SignUp)

-(void)registerUser:(RAUserDataModel*)user withCompletion:(RALoginCompletionBlock)handler;

@end

typedef void(^RALogoutCompletionBlock)(NSError * _Nullable error);

@interface RASessionManager (SignOut)

-(void)logoutWithCompletion:(RALogoutCompletionBlock _Nullable)handler;

@end

typedef void(^RARecoverPasswordCompletionBlock)(NSError * _Nullable error);

@interface RASessionManager (ForgotPassword)

-(void)recoverPasswordFromEmail:(NSString*)email withCompletion:(RARecoverPasswordCompletionBlock)hanlder;

@end

@interface RASessionManager (ChangePassword)
-(void)updatePassword:(NSString *)newPassword withCompletion:(void(^)(NSError *error))handler;
@end

typedef void(^RAUpdateUserCompletionBlock)(RAUserDataModel * _Nullable user, NSError * _Nullable error);

@interface RASessionManager (User)

-(void)reloadCurrentRiderWithCompletion:(void (^ _Nullable)(RARiderDataModel *rider, NSError *error))completion;

-(void)updateUserEmail:(NSString*)email firstname:(NSString*)firstname lastname:(NSString*)lastname phoneNumber:(NSString*)phoneNumber withCompletion:(RAUpdateUserCompletionBlock)handler;
-(void)updateUserGender:(NSString *)gender withCompletion:(RAUpdateUserCompletionBlock)completion;
-(void)updateUserPhoto:(UIImage*)photo withCompletion:(RAUpdateUserCompletionBlock)handler;

@end
NS_ASSUME_NONNULL_END
