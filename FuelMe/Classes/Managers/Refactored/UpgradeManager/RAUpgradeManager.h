//
//  RAUpgradeManager.h
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAConfigAppDataModel.h"

typedef void(^RAUpgradeVerificationBlock)(BOOL shouldUpgrade, BOOL isMandatory, NSError * _Nullable error);

@interface RAUpgradeManager : NSObject

+ (RAUpgradeManager* _Nonnull)sharedManager;

- (void)verifyUpgradeWithCompletion:(_Nullable RAUpgradeVerificationBlock)handler;

@end
