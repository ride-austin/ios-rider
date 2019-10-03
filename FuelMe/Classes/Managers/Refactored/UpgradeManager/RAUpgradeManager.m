//
//  RAUpgradeManager.m
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAUpgradeManager.h"
#import "RAMacros.h"
#import "RARideAPI.h"
#import "RASessionManager.h"
#import "UIAlertController+Show.h"
#import "RAAlertManager.h"

@interface RAUpgradeManager ()

@property (nonatomic, strong) RAConfigAppDataModel *currentAppConfiguration;

@property (nonatomic, getter=isAlertShown) BOOL alertShown;
@property (nonatomic, readonly) BOOL shouldShowOptionalUpgrade;

@property (nonatomic) BOOL verificationInProgress;
@property (nonatomic, copy) RAUpgradeVerificationBlock upgradeVerificationHandler;

@end

@interface RAUpgradeManager (Notifications)

- (void)appDidBecomeActiveNotification:(NSNotification*)notification;
- (void)didSignOutNotification:(NSNotification*)notification;

@end

@interface RAUpgradeManager (Alert)

- (void)showAlert;

@end

@interface RAUpgradeManager (Cache)

- (NSDate *)getLastDateOptionalUpgradeWasShown;
- (void)saveDateWhenOptionalUpgradeShown:(NSDate*)date;

@end

typedef void(^RAGetConfigAppBlock)(NSError *error);

@interface RAUpgradeManager (Private)

- (void)reloadDataWithCompletion:(RAGetConfigAppBlock)handler;

@end

static RAUpgradeManager *_sharedManager = nil;

static NSTimeInterval const kMinTimeInterval = 12*3600; // 12 hours minimum to show again the upgrading message if not mandatory.

@implementation RAUpgradeManager

+ (RAUpgradeManager *)sharedManager{
    if (!_sharedManager) {
        _sharedManager = [RAUpgradeManager new];
    }
    return  _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.alertShown = NO;
        self.verificationInProgress = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignOutNotification:) name:kDidSignoutNotification object:nil];

        __weak RAUpgradeManager *weakSelf = self;
        [[RANetworkManager sharedManager] addReachabilityObserver:self statusChangedBlock:^(RANetworkReachability networkReachability) {
            if (networkReachability == RANetworkReachable) {
                [weakSelf verifyUpgradeWithCompletion:nil];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSignoutNotification object:nil];
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

- (BOOL)shouldShowOptionalUpgrade {
    if (self.currentAppConfiguration.shouldUpgrade && !self.currentAppConfiguration.isMandatory) {
        NSDate *today = [NSDate date];
        NSDate *last = [self getLastDateOptionalUpgradeWasShown];
        if (last) {
            NSTimeInterval ti = [today timeIntervalSinceDate:last];
            return (ti > kMinTimeInterval);
        } else{
            return YES;
        }
    }
    return NO;
}

- (void)verifyUpgradeWithCompletion:(RAUpgradeVerificationBlock)handler {
#ifdef AUTOMATION
    if (handler) {
        handler(NO,NO,nil);
    }
    return;
#else
    if (!self.verificationInProgress) {
        self.verificationInProgress = YES;
        __weak RAUpgradeManager *weakSelf = self;
        [self reloadDataWithCompletion:^(NSError *error) {
            weakSelf.verificationInProgress = NO;
            
            if (!error) {
                //Optional upgrade is shown if the time interval is good. For mandatory only if user is in a ride. https://issue-tracker.devfactory.com/browse/RA-5884
                //If in a ride should let finish even if mandatory: https://issue-tracker.devfactory.com/browse/RA-8811
                //could show mandatory upgrade if the user just logged in and the app is still synchronizing ride. --> RA-9369
                //fix for RA-9369: ask server for current status (in case it is authed)
                
                if ([[RASessionManager sharedManager] isSignedIn]) {
                    [RARideAPI getCurrentRideWithCompletion:^(RARideDataModel *ride, NSError *error) {
                        if (([weakSelf shouldShowOptionalUpgrade] || ([weakSelf.currentAppConfiguration mustUpgrade] && !ride))) {
                            [weakSelf showAlert];
                        }
                    }];
                }
                else {
                    if (([weakSelf shouldShowOptionalUpgrade] || [weakSelf.currentAppConfiguration mustUpgrade])) {
                        [weakSelf showAlert];
                    }
                }
            }
            else {
                DBLog(@"reloadData upgrade error: %@",error);
            }
            
            BOOL shouldUpdate = weakSelf.currentAppConfiguration.shouldUpgrade;
            BOOL isMandatory = weakSelf.currentAppConfiguration.isMandatory;
            
            if (handler) {
                handler(shouldUpdate, isMandatory, error);
            }
            else if (weakSelf.upgradeVerificationHandler){
                weakSelf.upgradeVerificationHandler(shouldUpdate, isMandatory, error);
            }
            
            weakSelf.upgradeVerificationHandler = nil;
        }];
    }
    else{
        if (handler) {
            self.upgradeVerificationHandler = handler;
        }
    }
#endif
}

@end

#pragma mark - Notifications

@implementation RAUpgradeManager (Notifications)

- (void)appDidBecomeActiveNotification:(NSNotification *)notification {
    [self verifyUpgradeWithCompletion:nil];
}

- (void)didSignOutNotification:(NSNotification *)notification {
    [self saveDateWhenOptionalUpgradeShown:nil];
}

@end

#pragma mark - Alert

@implementation RAUpgradeManager (Alert)

- (void)showAlert {
    if (![self isAlertShown]) {
        
        self.alertShown = YES;
        
        __weak RAUpgradeManager *weakSelf = self;
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
            weakSelf.alertShown = NO;
        }];

        UIAlertAction *upgradeAction = [UIAlertAction actionWithTitle:@"Go to AppStore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
            weakSelf.alertShown = NO;
            
            if([[UIApplication sharedApplication] canOpenURL:weakSelf.currentAppConfiguration.upgradeURL]){
                [[UIApplication sharedApplication] openURL:weakSelf.currentAppConfiguration.upgradeURL];
            }
            else{
                [RAAlertManager showErrorWithAlertItem:[NSString stringWithFormat: @"Cannot open: %@", self.currentAppConfiguration.upgradeURL.absoluteString] andOptions:nil];
            }
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"A newer version is available with additional features. Please download from the App Store." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:upgradeAction];

        if (![self.currentAppConfiguration isMandatory]) {
            [alert addAction:cancelAction];
        }
        
        [alert show];
        
        if (!self.currentAppConfiguration.isMandatory) { //Saved only for optional upgrading but, in fact, doesn't matter to store date even if it is mandatory ...
            [self saveDateWhenOptionalUpgradeShown:[NSDate date]];
        }
    }
}

@end

#pragma mark - Cache

static NSString *const kLastOptionalUpgradeMessageShownDateUD = @"kLastOptionalUpgradeMessageShownDateUD";

@implementation RAUpgradeManager (Cache)

-(NSDate *)getLastDateOptionalUpgradeWasShown{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastOptionalUpgradeMessageShownDateUD];
}

-(void)saveDateWhenOptionalUpgradeShown:(NSDate *)date{
    if (!date) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastOptionalUpgradeMessageShownDateUD];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastOptionalUpgradeMessageShownDateUD];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

#pragma mark - Private 

#import "RAConfigAPI.h"

@implementation RAUpgradeManager (Private)

-(void)reloadDataWithCompletion:(RAGetConfigAppBlock)handler{
    
    __weak RAUpgradeManager *weakSelf = self;
    
    [RAConfigAPI getAppConfigurationWithCompletion:^(RAConfigAppDataModel *appConfiguration, NSError *error) {
        weakSelf.currentAppConfiguration = appConfiguration;
        
        if (handler) {
            handler(error);
        }
    }];        
}

@end
