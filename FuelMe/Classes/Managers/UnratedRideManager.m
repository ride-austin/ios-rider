//
//  UnratedRideManager.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//
#import "ConfigurationManagerConstants.h"
#import "ConfigTipping.h"
#import "UnratedRideManager.h"
#import "UnratedRide.h"
#import "RACacheManager.h"
#import "RARideAPI.h"
#import "RASessionManager.h"

@interface UnratedRideManager()

@property (nonatomic) NSMutableDictionary <NSString *, NSString *> *ridesToRate;
@property (nonatomic) NSMutableDictionary <NSString *, UnratedRide *> *ridesToSubmit;
@property (nonatomic) NSOperationQueue *queue;

@end

@interface UnratedRideManager(Cache)

+ (void)saveRidesToSubmitCollection:(NSDictionary *)ridesToSubmit;
+ (void)saveRidesToRateCollection:(NSDictionary *)ridesToRate;
+ (NSDictionary *)cachedRidesToSubmit;
+ (NSDictionary *)cachedRidesToRate;

@end

@implementation UnratedRideManager

+ (instancetype)shared {
    static UnratedRideManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 1;
        if ([RASessionManager sharedManager].isSignedIn) {
            [self configureDataForCurrentUser];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTippingConfiguration:) name:kNotificationDidChangeTippingSettings object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignin) name:kDidSigninNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:kDidSignoutNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSNumber *)tipLimit {
    if (![_tipLimit isKindOfClass:[NSNumber class]]) {
        _tipLimit = @(300);
    }
    return _tipLimit;
}

- (void)syncRidesToRate {
    [UnratedRideManager saveRidesToRateCollection:self.ridesToRate];
}

- (void)syncRidesToSubmit {
    [UnratedRideManager saveRidesToSubmitCollection:self.ridesToSubmit];
}

+ (NSString *)checkRideToRate {
    [UnratedRideManager checkForRatedRides];
    return [UnratedRideManager shared].ridesToRate.allKeys.firstObject;
}

- (void)configureDataForCurrentUser {
    self.ridesToRate   = [NSMutableDictionary dictionaryWithDictionary:[UnratedRideManager cachedRidesToRate]];
    self.ridesToSubmit = [NSMutableDictionary dictionaryWithDictionary:[UnratedRideManager cachedRidesToSubmit]];
}

+ (void)addUnratedRide:(NSString *)rideIDtoAdd {
    [[UnratedRideManager shared].ridesToRate setObject:rideIDtoAdd forKey:rideIDtoAdd];
    [[UnratedRideManager shared] syncRidesToRate];
}

+ (void)addRideToSubmit:(UnratedRide *)ride {
    [[UnratedRideManager shared] addRideToSubmit:ride];
}

- (void)addRideToSubmit:(UnratedRide *)ride {
    [self.ridesToSubmit setObject:ride forKey:ride.rideID];
    [self syncRidesToSubmit];
    
    [self.ridesToRate removeObjectForKey:ride.rideID];
    [self syncRidesToRate];
    
    [self submitRide:ride];
}

+ (void)checkForRatedRides {
    [[UnratedRideManager shared] submitRides];
}

- (void)submitRides {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (NSString *key in self.ridesToSubmit.allKeys.copy) {
            UnratedRide *ride = self.ridesToSubmit[key];
            [self submitRide:ride];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)submitRide:(UnratedRide *)unratedRide {
    [RARideAPI rateRide:unratedRide.rideID
             withRating:unratedRide.userRating
                    tip:unratedRide.validatedTip
             andComment:unratedRide.userComment
        paymentProvider:unratedRide.paymentMethodRequestParameter
         withCompletion:^(RARideDataModel *ride, NSError *error) {
             
             if (error) {
                 BOOL tippingHasPassed = [error.localizedRecoverySuggestion isEqualToString:@"\"Tipping period has passed\""];
                 BOOL rideAlreadyRated = [error.localizedRecoverySuggestion containsString:@"Ride already rated"];
                 BOOL rideAlreadyRated2 = [error.localizedRecoverySuggestion containsString:@"This ride has already been rated"];
                 if (error.code == 400) {
                     if (tippingHasPassed) {
                         unratedRide.userTip = nil;
                         [self.ridesToSubmit setObject:unratedRide forKey:unratedRide.rideID];
                     } else if (rideAlreadyRated || rideAlreadyRated2) {
                         [self.ridesToSubmit removeObjectForKey:unratedRide.rideID];
                     } else {
                         [self.ridesToSubmit removeObjectForKey:unratedRide.rideID];
                     }
                 }
             } else {
                 [self.ridesToSubmit removeObjectForKey:unratedRide.rideID];
                 //Check if need to process PaymentProvider
                 if ([ride.paymentProvider isEqualToString:@"BEVO_BUCKS"] && [[UIApplication sharedApplication] canOpenURL:ride.bevoBucksUrl]) {
                     [[UIApplication sharedApplication] openURL:ride.bevoBucksUrl];
                 }
             }
             
             [self syncRidesToSubmit];
         }];
}

#pragma mark Observers

- (void)didLogout {
    [self.ridesToRate   removeAllObjects];
    [self.ridesToSubmit removeAllObjects];
}

- (void)didSignin {
    [self configureDataForCurrentUser];
}

- (void)didChangeTippingConfiguration:(NSNotification *)note {
    ConfigTipping *tipping = note.object;
    if (tipping.tipLimit && ![self.tipLimit isEqualToNumber:tipping.tipLimit]) {
        self.tipLimit = tipping.tipLimit;
    }
}

@end

//
//  cache keys
//
static NSString *kUnratedRidesToSubmit          = @"kUnratedRidesToSubmit_4_9";
static NSString *kUnratedRidesToRate            = @"kUnratedRidesToRate_4_9";

@implementation UnratedRideManager(Cache)

+ (void)saveRidesToSubmitCollection:(NSDictionary *)ridesToSubmit {
    [RACacheManager cacheObject:ridesToSubmit forKey:kUnratedRidesToSubmit];
}

+ (void)saveRidesToRateCollection:(NSDictionary *)ridesToRate {
    [RACacheManager cacheObject:ridesToRate forKey:kUnratedRidesToRate];
}

+ (NSDictionary *)cachedRidesToSubmit {
    if ([RACacheManager cachedObjectForKey:@"kUnratedRidesToSubmit"]) {
        [RACacheManager removeObjectForKey:@"kUnratedRidesToSubmit"];
    }
    return [RACacheManager cachedObjectForKey:kUnratedRidesToSubmit];
}

+ (NSDictionary *)cachedRidesToRate {
    if ([RACacheManager cachedObjectForKey:@"kUnratedRidesToRate"]) {
        [RACacheManager removeObjectForKey:@"kUnratedRidesToRate"];
    }
    return [RACacheManager cachedObjectForKey:kUnratedRidesToRate];
}

@end
