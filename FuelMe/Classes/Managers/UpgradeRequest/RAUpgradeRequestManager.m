//
//  RAUpgradeRequestManager.m
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAUpgradeRequestManager.h"
#import "NSObject+SVProgressHUD.h"
#import "RARideAPI.h"
#import "RAUpgradeRequestPopUpView.h"
#import "RAAlertManager.h"
@interface RAUpgradeRequestManager ()

@property (nonatomic, strong) RAUpgradeRequestPopUpView *popUpView;

- (void)hideUpgradePopup;

@end

@interface RAUpgradeRequestManager (Persistence)

- (BOOL)popUpAlreadyShownForRide:(NSString*)ride;
- (void)setPopUpAlreadyShownForRide:(NSString*)ride;
- (NSString*)popUpAlreadyShownKeyForRide:(NSString*)ride;
- (void)cleanCache;

@end

@interface RAUpgradeRequestManager (PopUpDelegate)<RAPopUpViewDelegate>

@end

@implementation RAUpgradeRequestManager

+ (RAUpgradeRequestManager *)sharedManager {
    static dispatch_once_t onceToken;
    static RAUpgradeRequestManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RAUpgradeRequestManager alloc] init];
    });
    return sharedInstance;
}

- (void)showOrHidePopUpForUpgradeRequest:(RARideUpgradeRequestDataModel *)upgradeRequest andRide:(NSString*)ride {
    if (!upgradeRequest) {
        [self hideUpgradePopup];
        return;
    }
    
    if (upgradeRequest.upgradeStatus == RAURSExpired && self.popUpView) {
        [self hideUpgradePopup];
        [RAAlertManager showAlertWithTitle:@"Upgrade Request" message:[NSString stringWithFormat:@"The request to upgrade to %@ class has expired",upgradeRequest.target]];
    } else if (upgradeRequest.upgradeStatus == RAURSCancelled) {
        [self hideUpgradePopup];
        [RAAlertManager showAlertWithTitle:@"Upgrade Request" message:[NSString stringWithFormat:@"Your driver has cancelled the upgrade to %@ class",upgradeRequest.target]];
    } else if (upgradeRequest.upgradeStatus == RAURSRequested && !self.popUpView && ![self popUpAlreadyShownForRide:ride]) {
        NSString *source = upgradeRequest.source;
        //FIX to display STANDARD should be fixed on server side
        if ([source isEqualToString:@"REGULAR"]) {
            source = @"STANDARD";
        }
        NSString *target = upgradeRequest.target;
        double surge = upgradeRequest.surgeFactor.doubleValue;
        
        self.popUpView = [RAUpgradeRequestPopUpView showUpgradeRequestPopUpViewWithDelegate:self
                                                                                     source:source
                                                                                     target:target
                                                                                surgeFactor:surge
                                                                                     rideID:ride
                          ];
    } else if (upgradeRequest.upgradeStatus != RAURSRequested && upgradeRequest.upgradeStatus != RAURSCancelled && upgradeRequest.upgradeStatus != RAURSExpired) { //Any other status
        [self hideUpgradePopup];
    }
}

- (void)hideUpgradePopup {
    if (self.popUpView) {
        [self.popUpView dismiss];
        self.popUpView = nil;
    }
}

- (void)rideHasFinished {
    [self cleanCache];
    [self hideUpgradePopup];
}

@end

#pragma mark - Persistence

static NSString *const kUpgradeRequestAlreadyShownUDKey = @"kUpgradeRequestAlreadyShownUDKey";

@implementation RAUpgradeRequestManager (Persistence)

- (BOOL)popUpAlreadyShownForRide:(NSString *)ride {
    NSString *key = [self popUpAlreadyShownKeyForRide:ride];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setPopUpAlreadyShownForRide:(NSString *)ride {
    NSString *key = [self popUpAlreadyShownKeyForRide:ride];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

- (NSString *)popUpAlreadyShownKeyForRide:(NSString *)ride {
    return [NSString stringWithFormat:@"%@.%@",kUpgradeRequestAlreadyShownUDKey,ride];
}

- (void)cleanCache {
    NSArray *allUserDefaultsKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    NSPredicate *stringStartsWithPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",kUpgradeRequestAlreadyShownUDKey];
    NSArray *keys = [allUserDefaultsKeys filteredArrayUsingPredicate:stringStartsWithPredicate];
    
    for (NSString *key in keys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

#pragma mark - Pop Up Delegate

@implementation RAUpgradeRequestManager (PopUpDelegate)

- (void)popUpView:(RAPopUpView *)popUpView hasBeenDismissedWithButton:(RAPopUpButton)button {
    NSString *rideID = [(RAUpgradeRequestPopUpView*)popUpView rideID];
    self.popUpView = nil;

    if (button == RAPUButtonAccept) {
        [self showHUD];
        
        [RARideAPI confirmUpgradingCurrentRideWithCompletion:^(NSError *error) {
            [self hideHUD:error==nil status:@"Success"];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error
                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            }
            else {
                [self setPopUpAlreadyShownForRide:rideID];
            }
        }];
    } else {
        [self showHUD];
        [RARideAPI declineUpgradingCurrentRideWithCompletion:^(NSError *error) {
            [self hideHUD];
            if (!error) {
                [self setPopUpAlreadyShownForRide:rideID];
            }
        }];
    }
}

@end

@implementation RAUpgradeRequestManager (RideStatus)

+ (void)didChangeRideStatus:(RARideStatus)rideStatus {
    switch (rideStatus) {
        case RARideStatusUnknown:
        case RARideStatusNone:
        case RARideStatusPrepared:
        case RARideStatusRequested:
        case RARideStatusNoAvailableDriver:
        case RARideStatusRiderCancelled:
        case RARideStatusDriverCancelled:
        case RARideStatusAdminCancelled:
        case RARideStatusCompleted:
            [[RAUpgradeRequestManager sharedManager] rideHasFinished];
            break;
            
        case RARideStatusRequesting:
        case RARideStatusDriverAssigned:
        case RARideStatusDriverReached:
        case RARideStatusActive:
            break;
    }
}

@end
