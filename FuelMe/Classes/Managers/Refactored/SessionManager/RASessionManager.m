//
//  RASessionManager.m
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RASessionManager.h"

#import "LocationService.h"
#import "NSError+ErrorFactory.h"
#import "NSNotificationCenterConstants.h"
#import "RAMacros.h"
#import "RARideManager.h"
#import "RARiderAPI.h"
#import "RASessionAPI.h"
#import "RAUserAPI.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SAMKeychain/SAMKeychain.h>


NSString *const RAKVOCurrentSession = @"currentSession";
NSString *const RAKVORegistering = @"registering";

NSString *const kDidSigninNotification = @"kDidSigninNotification";
NSString *const kDidSignoutNotification = @"kDidSignoutNotification";

NSString *const sessionServiceKeychain = @"session";
NSString *const accountKeychain = @"com.rideaustin";

static NSString *const kSessionManagerUDKeyCurrentSession = @"kSessionManagerUDKeyCurrentSession";
static NSString *const kSessionManagerUDKeyNeedsToRegisterPhone = @"kSessionManagerUDKeyNeedsToRegisterPhone";

@interface RASessionManager ()

@property (nonatomic) BOOL needsToRegisterPhone;
@property (nonatomic, strong) RASessionDataModel *currentSession;

@end

@interface RASessionManager (Private)

- (void)loginWithUsername:(NSString*)username password:(NSString*)password isFacebookUser:(BOOL)fbUser andCompletion:(RALoginCompletionBlock) handler;

@end

@interface RASessionManager (Persistence)

- (RASessionDataModel*)recoverSession;
- (void)saveSession:(RASessionDataModel*)session;

//Not really needed persistence here.
- (void)registerDefaults;
- (BOOL)getNeedsToRegisterPhone;
- (void)saveNeedsToRegisterPhone:(BOOL)needs;

@end

@implementation RASessionManager
@synthesize currentSession = _currentSession;

+ (void)load {
    [RASessionManager sharedManager];
}

+ (RASessionManager *)sharedManager {
    static RASessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RASessionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self registerDefaults];
        if (self.currentUser && self.needsToRegisterPhone) {
            [self logoutWithCompletion:nil];
        } else {
            [[RANetworkManager sharedManager] setAuthToken:self.currentSession.authToken];
        }
    }
    return self;
}

- (RAUserDataModel *)currentUser {
    return [self.currentSession rider].user;
}

- (RARiderDataModel *)currentRider {
    return [self.currentSession rider];
}

- (void)setCurrentRider:(RARiderDataModel *)currentRider {
    RASessionManager *sessionManager = [RASessionManager sharedManager];
    RASessionDataModel *currentSession = [sessionManager currentSession] ?: [[RASessionDataModel alloc] init];
    [currentSession setRider:currentRider];
    [sessionManager setCurrentSession:currentSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidUpdateCurrentRider object:nil];
}

- (RASessionDataModel *)currentSession {
    if (!_currentSession) {
        _currentSession = [self recoverSession];
    }
    return _currentSession;
}

- (void)setCurrentSession:(RASessionDataModel *)currentSession {
    _currentSession = currentSession;
    if (currentSession) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSigninNotification object:nil];
    }
    [self saveSession:currentSession];
}

- (void)clearCurrentSession {
    [[RARideManager sharedManager] removeCurrentRide]; //clear current ride before currentSession
    self.needsToRegisterPhone = NO;
    [self setCurrentSession:nil];
    [[LocationService sharedService] stop];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[RANetworkManager sharedManager] cancelAllOperations];
    
    if([FBSDKAccessToken currentAccessToken] != nil) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    [self clearHeader];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSignoutNotification object:nil];
}

- (void)clearHeader {
    [RANetworkManager sharedManager].authToken = nil;
}

- (BOOL)needsToRegisterPhone {
    return [self getNeedsToRegisterPhone];
}

- (void)setNeedsToRegisterPhone:(BOOL)needsToRegisterPhone {
    [self saveNeedsToRegisterPhone:needsToRegisterPhone];
}

- (BOOL)isSignedIn {
    return (self.currentSession.authToken && self.currentUser != nil && !self.needsToRegisterPhone);
}

+ (BOOL)hasAuthToken {
    return [RASessionManager sharedManager].currentSession.authToken != nil;
}

- (BOOL)isLoggedWithFacebok {
    return [FBSDKAccessToken currentAccessToken] != nil;
}

- (void)saveContext {
    [self saveSession:self.currentSession];
}

@end

@implementation RASessionManager (SignIn)

- (void)loginWithUsername:(NSString *)username password:(NSString *)password andCompletion:(RALoginCompletionBlock)handler {
    [self loginWithUsername:username password:password isFacebookUser:NO andCompletion:handler];
}

- (void)loginWithFacebookFromViewController:(UIViewController *)viewController andCompletion:(RALoginCompletionBlock)handler {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithPermissions:@[@"public_profile", @"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            BOOL userDidntAllowToOpenFacebook = [error.domain isEqualToString:@"com.apple.SafariServices.Authentication"] && error.code == 1;
            if (userDidntAllowToOpenFacebook) {
                error = nil;
            }
            if (handler) {
                handler(nil, error);
            }
        }
        else if (result.isCancelled){
            if (handler) {
                handler(nil, nil);
            }
        }
        else {
            
            FBSDKGraphRequest *gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,email,first_name,last_name"}];
            [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                if (error) {
                    if (handler) {
                        handler(nil, error);
                    }
                    return;
                }
                
                NSString *email = result[@"email"];
                
                if (!email) {
                    if (handler) {
                        handler(nil, NSError.facebookEmailNotProvidedError);
                    }
                    
                }
                else {
                    NSString* facebookToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                    DBLog(@"Session manager - loginWithFB facbook- token: %@",facebookToken);
                    [RASessionAPI loginWithFacebook:facebookToken andCompletion:^(NSError *error) {
                        self.needsToRegisterPhone = (error.code == NSError.facebookPhoneNotProvidedError.code);

                        if (!error) {
                            
                            [self loginWithUsername:email password:facebookToken isFacebookUser:YES andCompletion:^(RAUserDataModel *user, NSError *error) {
                                if (handler) {
                                    handler(user, error);
                                }
                            }];
                            
                        } else {
                            RAUserDataModel *fbUser = nil;
                            if (self.needsToRegisterPhone) {
                                fbUser = [[RAUserDataModel alloc] init];
                                fbUser.email = email;
                                fbUser.password = facebookToken;
                            }
                            
                            if (handler) {
                                handler(fbUser, error);
                            }
                        }
                        
                    }];
                }
            }];
        }
    }];
}

@end

@implementation RASessionManager (SignUp)

- (void)registerUser:(RAUserDataModel *)user withCompletion:(RALoginCompletionBlock)handler {
    DBLog(@"register user: %@ - %@ - %@ - %@ - %@",user.firstname, user.lastname, user.email, user.phoneNumber, user.password);
    
    [RAUserAPI createUser:user withCompletion:^(RAUserDataModel *serverUser, NSError *error) {
        if (!error) {
            
            DBLog(@"login with user: %@ - %@",user.email, user.password);

            [[RASessionManager sharedManager] loginWithUsername:user.email password:user.password isFacebookUser: self.isLoggedWithFacebok andCompletion:^(RAUserDataModel *user, NSError *error) {
                DBLog(@"user registered - login error: %@",error);
                
                if (handler) {
                    handler(user,error);
                }
            }];
            
        }
        else {
            DBLog(@"user registered error: %@",error);
            //RA-9330: After creating user network is switched off and login is not possible, so if received error 400 (user already exists), try to login.
            if (error.code == 400) {
                DBLog(@"login with user after error 400: %@ - %@",user.email, user.password);
                
                [[RASessionManager sharedManager] loginWithUsername:user.email password:user.password isFacebookUser: self.isLoggedWithFacebok andCompletion:^(RAUserDataModel *user, NSError *error) {
                    DBLog(@"user registered error 400 - login error: %@",error);
                    
                    if (handler) {
                        handler(user,error);
                    }
                }];
                
            }
            else {
                if (handler) {
                    handler(nil,error);
                }
            }
        }

    }];
}

@end

@implementation RASessionManager (SignOut)

- (void)logoutWithCompletion:(RALogoutCompletionBlock)handler {
    if ([self isSignedIn]) {
        __weak RASessionManager *weakSelf = self;
        [RASessionAPI logoutWithCompletion:^(id responseObject, NSError *error) {
            [weakSelf clearCurrentSession];
            if (handler) {
                handler(error);
            }
        }];
    } else {
        //Just in case
        [self clearCurrentSession];
        if (handler) {
            handler(nil);
        }
    }
}

@end

@implementation RASessionManager (ForgotPassword)

- (void)recoverPasswordFromEmail:(NSString *)email withCompletion:(RARecoverPasswordCompletionBlock)handler {
    [RASessionAPI recoverPasswordFromEmail:email withCompletion:^(id responseObject, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

@end

@implementation RASessionManager (ChangePassword)

- (void)updatePassword:(NSString *)newPassword withCompletion:(void(^)(NSError *error))handler {
    NSString *email = [self currentUser].email;
    NSString *securePassword = [RAUserDataModel securePasswordWithEmail:email andPassword:newPassword];
    [RASessionAPI updatePassword:securePassword withCompletion:^(id responseObject, NSError *error) {
        handler(error);
    }];
}

@end

@implementation RASessionManager (Persistence)

- (void)registerDefaults {
    NSDictionary *defaultPreferences = @{ kSessionManagerUDKeyNeedsToRegisterPhone : [NSNumber numberWithBool:NO] };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
}

- (RASessionDataModel *)recoverSession {
#pragma mark - NSUserDefaults could be removed for next version 4.7 (here, just to avoid logout current user)
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionManagerUDKeyCurrentSession];
    if (data) {
        [SAMKeychain setPasswordData:data forService:sessionServiceKeychain account:accountKeychain];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionManagerUDKeyCurrentSession];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    data = [SAMKeychain passwordDataForService:sessionServiceKeychain account:accountKeychain];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return nil;
}

- (void)saveSession:(RASessionDataModel *)session {
    if (session) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:session];
        [SAMKeychain setPasswordData:data forService:sessionServiceKeychain account:accountKeychain];
    } else {
        [SAMKeychain deletePasswordForService:sessionServiceKeychain account:accountKeychain];
    }
}

- (BOOL)getNeedsToRegisterPhone {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSessionManagerUDKeyNeedsToRegisterPhone];
}

- (void)saveNeedsToRegisterPhone:(BOOL)needs {
    [[NSUserDefaults standardUserDefaults] setBool:needs forKey:kSessionManagerUDKeyNeedsToRegisterPhone];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

#pragma mark - User

@implementation RASessionManager (User)

- (void)reloadCurrentRiderWithCompletion:(void (^)(RARiderDataModel *rider, NSError *error))completion {
    __weak __typeof__(self) weakself = self;
    [RARiderAPI getCurrentRiderWithCompletion:^(RARiderDataModel *rider, NSError *error) {
        if (!error) {
            [weakself setCurrentRider:rider];
        }
        if (completion) {
            completion(rider,error);
        }
    }];
}

- (void)updateUserEmail:(NSString *)email firstname:(NSString *)firstname lastname:(NSString *)lastname phoneNumber:(NSString *)phoneNumber withCompletion:(RAUpdateUserCompletionBlock)handler {
    RAUserDataModel *updatedUser = [self.currentUser copy];
    updatedUser.email = email;
    updatedUser.firstname = firstname;
    updatedUser.lastname = lastname;
    updatedUser.phoneNumber = phoneNumber;
    
    [RAUserAPI updateUser:updatedUser withCompletion:^(RAUserDataModel *user, NSError *error) {
        if (!error) {
            RARiderDataModel *currentRider = [[RASessionManager sharedManager] currentRider];
            currentRider.user = user;
            [[RASessionManager sharedManager] saveContext];
        }
        
        if (handler) {
            handler(user, error);
        }
    }];
}

- (void)updateUserGender:(NSString *)gender withCompletion:(RAUpdateUserCompletionBlock)completion {
    RAUserDataModel *updatedUser = self.currentUser.copy;
    updatedUser.gender = gender;
    
    [RAUserAPI updateUser:updatedUser withCompletion:^(RAUserDataModel *user, NSError *error) {
        if (!error) {
            RARiderDataModel *currentRider = [[RASessionManager sharedManager] currentRider];
            currentRider.user = user;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidUpdateCurrentUserGender object:gender];
            [[RASessionManager sharedManager] saveContext];
        }
        
        if (completion) {
            completion(user, error);
        }
    }];
}

- (void)updateUserPhoto:(UIImage *)photo withCompletion:(RAUpdateUserCompletionBlock)handler {
    [RAUserAPI updatePhoto:photo forUser:self.currentUser withCompletion:handler];
}

@end

#pragma mark - Private

@implementation RASessionManager (Private)

- (void)loginWithUsername:(NSString *)username password:(NSString *)password isFacebookUser:(BOOL)fbUser andCompletion:(RALoginCompletionBlock)handler {
    
    [RASessionAPI loginWithUsername:username password:password encrypt:!fbUser andCompletion:^(RASessionDataModel *session, NSError *error) {
        
        if (!error) {
            
            self.needsToRegisterPhone = NO;
            
            [RARiderAPI getCurrentRiderWithCompletion:^(RARiderDataModel *rider, NSError *error) {
                if (error) {
                    if (handler) {
                        handler(nil, error);
                    }
                } else {
                    if (rider.user.enabled) {
                        [session setRider:rider];
                        [[RASessionManager sharedManager] setCurrentSession:session];
                        [[RANetworkManager sharedManager] setAuthToken:session.authToken];
                        
                        if (handler) {
                            handler(rider.user, nil);
                        }
                    } else {
                        DBLog(@"user not enabled");
                        [[RASessionManager sharedManager] logoutWithCompletion:nil];
                        if (handler) {
                            handler(nil, NSError.accountNotEnabledError);
                        }
                        
                    }
                }
            }];
        } else {
            if (handler) {
                handler(nil, error);
            }
        }
    }];
}

@end
