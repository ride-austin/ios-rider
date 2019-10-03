//
//  RASessionAPI.m
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAUserAPI.h"

#import "NSData+Base64.h"
#import "RAPhotosAPI.h"
#import "UIImage+Utils.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PersistenceManager.h"


static NSString *const kEmailField = @"email";
static NSString *const kPhoneField = @"phoneNumber";

@implementation RAUserAPI

+ (void)checkAvailabilityOfEmail:(NSString *)email withCompletion:(APICheckResponseBlock)handler {
    NSParameterAssert(email.length > 0);
    [RAUserAPI checkAvailabilityOfEmail:email andPhone:nil withCompletion:handler];
}

+ (void)checkAvailabilityOfPhone:(NSString *)phoneNumber withCompletion:(APICheckResponseBlock)handler {
    NSParameterAssert(phoneNumber.length > 0);
    [RAUserAPI checkAvailabilityOfEmail:nil andPhone:phoneNumber withCompletion:handler];
}

+ (void)checkAvailabilityOfEmail:(NSString *)email andPhone:(NSString *)phoneNumber withCompletion:(APICheckResponseBlock)handler {
    NSString *path = kPathUsersExists;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[kEmailField] = email;
    parameters[kPhoneField] = phoneNumber;
    
    [[RARequest requestWithPath:path
                        method:POST
                    parameters:parameters
                    errorDomain:POSTSignupAvailability
                       success:^(NSURLSessionTask *networkTask, id response) {
                           if (handler) {
                               handler(NO, nil);
                           }
                       }
                       failure:^(NSURLSessionTask *networkTask, NSError *error) {
                           if (handler) {
                               handler(YES, error);
                           }
                       }]
     execute];
}

+ (void)getFacebookUserData:(RAUserAPICompletionBlock)handler {
    FBSDKGraphRequest *gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,email,first_name,last_name"}];
    
    [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            if (handler) {
                handler(nil,error);
            }
        } else {
            
            NSString *firstName = result[@"first_name"];
            NSString *lastName  = result[@"last_name"];
            NSString *fbId      = result[@"id"];
            
            RAUserDataModel *fbUSer = [[RAUserDataModel alloc] init];
            fbUSer.firstname = firstName;
            fbUSer.lastname = lastName;
            fbUSer.photoURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbId]];
            
            if (handler) {
                handler(fbUSer,nil);
            }

        }
    }];
}

+ (void)createUser:(RAUserDataModel *)user withCompletion:(RAUserAPICompletionBlock)handler {
    
    NSString *imageStr = nil;
    if (user.picture) {
        UIImage *picture = [user.picture scaledToMaxArea:300000];
        NSData *imageData = UIImageJPEGRepresentation(picture, 1.0);
        imageStr = [imageData base64EncodedString];
    }
    
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSString *timeZone = [localTime abbreviation];
    
    NSParameterAssert(user.email.length > 0);
    NSParameterAssert(user.password.length > 0);
    NSString *sPassword = [RAUserDataModel securePasswordWithEmail:user.email andPassword:user.password];
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc]
                                    initWithDictionary:
                                    @{ @"email"      : user.email     ?: @"",
                                       @"firstname"  : user.firstname ?: @"",
                                       @"lastname"   : user.lastname  ?: @"",
                                       @"socialId"   : user.facebookID?: @"",
                                       @"phonenumber": user.phoneNumber ?: @"",
                                       @"data"       : imageStr ?:@"",
                                       @"password"   : sPassword,
                                       @"timeZone"   : timeZone
                                       }];
    
    NSDictionary * branchParams = [PersistenceManager cachedBranchParams];
    
    NSString* channel = [branchParams valueForKey: @"~channel"];
    NSString* promoCode = [branchParams valueForKey: @"promo_code"];
    NSString* marketingTitle = [branchParams valueForKey: @"$marketing_title"];
    NSString* feature = [branchParams valueForKey: @"~feature"];
    NSString* campaign = [branchParams valueForKey: @"~campaign"];
    
    if (channel) {
         [params setValue:channel forKey:@"utm_source"];
    }
    
    if (promoCode) {
         [params setValue:promoCode forKey:@"promo_code"];
    }
    
    if (marketingTitle) {
         [params setValue:marketingTitle forKey:@"marketing_title"];
    }
    
    if (feature) {
        [params setValue:feature forKey:@"utm_medium"];
    }
    
    if (campaign) {
        [params setValue:campaign forKey:@"utm_campaign"];
    }
    
    NSString *path = kPathUsers;
    
    [[RARequest requestWithPath:path method:POST parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RAUserDataModel class] fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            [PersistenceManager clearBranchParams];
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

+ (void)updateUser:(RAUserDataModel *)user withCompletion:(RAUserAPICompletionBlock)handler {
    NSParameterAssert([user.email       isKindOfClass:[NSString class]]);
    NSParameterAssert([user.firstname   isKindOfClass:[NSString class]]);
    NSParameterAssert([user.lastname    isKindOfClass:[NSString class]]);
    NSParameterAssert([user.phoneNumber isKindOfClass:[NSString class]]);
    NSMutableDictionary *params =
    @{ @"email"      : user.email,
       @"firstname"  : user.firstname,
       @"lastname"   : user.lastname,
       @"phoneNumber": user.phoneNumber
       }.mutableCopy;
    params[@"gender"]   = user.gender;
    params[@"nickName"] = user.nickName;
    
    NSString *path = [NSString stringWithFormat:kPathUsersSpecific, user.modelID.stringValue];
    
    RARequest *request = [RARequest requestWithPath:path method:PUT parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RAUserDataModel class] fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        RAUserDataModel *user = (RAUserDataModel*)response;
        if (!handler) { return; }
        
        if (user) {
            handler(user, nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"com.rideaustin.user.parse.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Bad user json", NSLocalizedFailureReasonErrorKey: @"Bad user json", NSLocalizedDescriptionKey: @"Bad user json"}];
            handler(nil, error);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }];
    
    request.parameterEncoding = JSON;
    [request execute];
}

+ (void)updatePhoto:(UIImage *)photo forUser:(RAUserDataModel *)user withCompletion:(RAUserAPICompletionBlock)handler {
    UIImage *userPhoto = [photo scaledToMaxArea:300000];
    
    [RAPhotosAPI uploadPhoto:userPhoto
                 errorDomain:POSTPhotosProfile
                    progress:nil
                  completion:^(NSString *photoUrl, NSError *error) {
                      if (!error && photoUrl) {
                          user.photoURL = [NSURL URLWithString:photoUrl];
                          
                          if (handler) {
                              handler(user,error);
                          }
                      }
                      else{
                          if (handler) {
                              handler(user,error);
                          }
                      }
                  }];
}

@end
