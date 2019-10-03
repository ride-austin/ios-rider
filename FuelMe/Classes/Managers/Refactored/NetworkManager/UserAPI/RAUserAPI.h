//
//  RASessionAPI.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseAPI.h"

#import "RAUserDataModel.h"

typedef void(^RAUserAPICompletionBlock)(RAUserDataModel* user, NSError *error);

@interface RAUserAPI : RABaseAPI

+ (void) checkAvailabilityOfEmail:(NSString*)email withCompletion:(APICheckResponseBlock)handler;
+ (void) checkAvailabilityOfPhone:(NSString*)phoneNumber withCompletion:(APICheckResponseBlock)handler;
+ (void) checkAvailabilityOfEmail:(NSString*)email andPhone:(NSString*)phoneNumber withCompletion:(APICheckResponseBlock)handler;
+ (void) getFacebookUserData:(RAUserAPICompletionBlock)handler;
+ (void) createUser:(RAUserDataModel*)user withCompletion:(RAUserAPICompletionBlock)handler;
+ (void) updateUser:(RAUserDataModel*)user withCompletion:(RAUserAPICompletionBlock)handler;
+ (void) updatePhoto:(UIImage*)photo forUser:(RAUserDataModel*)user withCompletion:(RAUserAPICompletionBlock)handler;

@end
