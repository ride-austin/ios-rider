//
//  RAConfigAPI.h
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigGlobal.h"
#import "RABaseAPI.h"
#import "RAConfigAppDataModel.h"

typedef void(^RAConfigAppCompletionBlock)(RAConfigAppDataModel * _Nullable appConfiguration, NSError *_Nullable error);

@interface RAConfigAPI : RABaseAPI

+ (void)getAppConfigurationWithCompletion:(_Nullable RAConfigAppCompletionBlock)handler;
+ (void)getGlobalConfigurationAtCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:( void (^ _Nonnull )(ConfigGlobal * _Nullable globalConfig, NSError * _Nullable error))completion;

@end
