//
//  RARideRequestManager.m
//  Ride
//
//  Created by Kitos on 18/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARideRequestManager.h"
#import "CLLocation+Utils.h"
#import "CLLocation+isValid.h"
#import "ConfigurationManager.h"
#import "RACacheManager.h"
#import "RASessionManager.h"
#import "NSNotificationCenterConstants.h"
//
//  cache keys
//
static NSString *kCurrentRideRequestCacheKey    = @"kCurrentRideRequestCacheKey-GreaterThan3dot3";
static NSString *kWomanOnlyModeCacheKey         = @"kWomanOnlyModeCacheKey";
static NSString *kFingerPrintedOnlyModeCacheKey = @"kFingerprintedOnlyModeCacheKey";

@interface RARideRequestManager ()

@property (nonatomic, strong) RARideRequest *currentRideRequest;

@end

@interface RARideRequestManager (Notifications)

- (void)addObservers;
- (void)removeObservers;
- (void)configurationHasChanged;
- (void)genderHasChanged:(NSNotification *)note;

@end

@interface RARideRequestManager (Cache)

- (void)saveCurrentRideRequest:(RARideRequest *)rideRequest;
- (RARideRequest *)cachedCurrentRideRequest;
- (void)cleanCache;

- (BOOL)cachedWomanOnlyMode;
- (void)saveWomanOnlyMode:(BOOL)womanOnlyMode;

- (BOOL)cachedFingerPrintedDriversOnlyMode;
- (void)saveFingerprintedDrivers:(BOOL)enabled;

@end

@interface RARideRequestManager (Private)

- (void)createCurrentRideRequestIfNeeded;

@end

RARideRequestManager *_sharedManager = nil;

@implementation RARideRequestManager

+ (RARideRequestManager *)sharedManager {
    if (!_sharedManager) {
        _sharedManager = [RARideRequestManager new];
    }
    return _sharedManager;
}

- (RARideRequest *)currentRideRequest {
    if (!_currentRideRequest) {
        _currentRideRequest = [self cachedCurrentRideRequest];
    }
        
    return _currentRideRequest;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderHasChanged:) name:kNotificationDidUpdateCurrentUserGender object:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

- (BOOL)isWomanOnlyModeOn {
    if ([[ConfigurationManager shared].global.womanOnly.eligibleGenders containsObject:[RASessionManager sharedManager].currentUser.gender]) {
        return [self cachedWomanOnlyMode];
    } else {
        return NO;
    }
}

- (BOOL)isFingerprintedDriverOnlyModeOn {
    return [self cachedFingerPrintedDriversOnlyMode];
}

- (void)setWomanOnlyModeOn:(BOOL)womanOnlyModeOn {
    [self saveWomanOnlyMode:womanOnlyModeOn];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidUpdateFemaleDriverSwitch object:@(womanOnlyModeOn)];
}

- (void)setIsFingerprintedDriverOnlyModeOn:(BOOL)isFingerprintedDriverOnlyModeOn {
    [self saveFingerprintedDrivers:isFingerprintedDriverOnlyModeOn];
}

- (void)riderHasSelectedPickUpLocation:(RARideLocationDataModel *)pickUpLocation {
    [self createCurrentRideRequestIfNeeded];
    self.currentRideRequest.startLocation = pickUpLocation;
    [self saveCurrentRideRequest:_currentRideRequest];
    [self notifyObserversForRequest:_currentRideRequest];
}

- (void)riderHasSelectedDestinationLocation:(RARideLocationDataModel *)destinationLocation {
    if (self.currentRideRequest) {
        self.currentRideRequest.endLocation = destinationLocation;
        [self saveCurrentRideRequest:_currentRideRequest];
        [self notifyObserversForRequest:_currentRideRequest];
    }
}

- (void)riderHasWrittenPickUpComment:(NSString *)pickUpComment {
    if (self.currentRideRequest) {
        self.currentRideRequest.comment = pickUpComment;
        [self saveCurrentRideRequest:_currentRideRequest];
    }
}

- (void)riderHasSelectedCategory:(RACarCategoryDataModel *)category {
    if (self.currentRideRequest) {
        self.currentRideRequest.carCategory = category;
        [self saveCurrentRideRequest:_currentRideRequest];
    }
}

- (void)deleteRideRequest {
    self.currentRideRequest = nil;
    [self cleanCache];
    [self notifyObserversForRequest:nil];
}

- (BOOL)allowsCategory:(RACarCategoryDataModel*)category {
    //  woman only mode allows premium and luxury only
    if ([self isWomanOnlyModeOn]) {
        RADriverTypeDataModel *config = [ConfigurationManager shared].global.womanOnly;
        return [config.eligibleCategories containsObject:category.carCategory];
    } else {
        return YES;
    }
}

- (void)reloadCurrentRideRequestWithPickupLocation:(RARideLocationDataModel *)pickupLocation andDestinationLocation:(RARideLocationDataModel *)destinationLocation {
    [self createCurrentRideRequestIfNeeded];
    
    RARideLocationDataModel *previousStartLocation = [self.currentRideRequest startLocation];
    if (previousStartLocation && [previousStartLocation.location isEqualToOtherLocation:pickupLocation.location]) {
        pickupLocation.visibleAddress = previousStartLocation.visibleAddress;
    }
    
    RARideLocationDataModel *previousEndLocation = [self.currentRideRequest endLocation];
    if (previousEndLocation && [previousEndLocation.location isEqualToOtherLocation:destinationLocation.location]) {
        destinationLocation.visibleAddress = previousEndLocation.visibleAddress;
    }
    
    self.currentRideRequest.startLocation = pickupLocation;
    self.currentRideRequest.endLocation = destinationLocation;
}

- (void)notifyObserversForRequest:(RARideRequest *)request {
    
    BOOL isFilled = NO;
    if (!request) {
        isFilled = NO;
    } else if (!request.startLocation.location.isValid) {
        isFilled = NO;
    } else if (!request.endLocation.location.isValid) {
        isFilled = NO;
    } else {
        isFilled = YES;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddressValuesFilled object:@(isFilled)];
}
@end

#pragma mark - Notifications

@implementation RARideRequestManager (Notifications)

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configurationHasChanged)
                                                 name:kNotificationDidChangeConfiguration
                                               object:nil];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDidChangeConfiguration object:nil];
}

- (void)configurationHasChanged {
    RADriverTypeDataModel *config = [ConfigurationManager shared].global.womanOnly;
    if (config) {
        [self setWomanOnlyModeOn:NO];
        if (self.currentRideRequest) {
            self.currentRideRequest.womanOnlyMode = NO;
        }
    }
}

- (void)genderHasChanged:(NSNotification *)note {
    NSString *gender = note.object;
    if ([[ConfigurationManager shared].global.womanOnly.eligibleGenders containsObject:gender] == NO) {
        [self setWomanOnlyModeOn:NO];
        if (self.currentRideRequest) {
            self.currentRideRequest.womanOnlyMode = NO;
        }
    }
}

@end

#pragma mark - Cache

@implementation RARideRequestManager (Cache)

- (void)saveCurrentRideRequest:(RARideRequest *)rideRequest {
    if (rideRequest) {
        [RACacheManager cacheObject:rideRequest forKey:kCurrentRideRequestCacheKey];
    }
    else {
        [self cleanCache];
    }
}

- (RARideRequest *)cachedCurrentRideRequest {
    return [RACacheManager cachedObjectForKey:kCurrentRideRequestCacheKey];
}

- (void)cleanCache {
    [RACacheManager removeObjectForKey:kCurrentRideRequestCacheKey];
}

- (BOOL)cachedWomanOnlyMode {
    return [RACacheManager cachedBoolForKey:kWomanOnlyModeCacheKey];
}

- (void)saveWomanOnlyMode:(BOOL)womanOnlyMode {
    [RACacheManager cacheBool:womanOnlyMode forKey:kWomanOnlyModeCacheKey];
}

- (BOOL)cachedFingerPrintedDriversOnlyMode {
    
    if ([RACacheManager cachedObjectForKey:kFingerPrintedOnlyModeCacheKey] == nil) {
        return NO;
    }
    
    return [RACacheManager cachedBoolForKey:kFingerPrintedOnlyModeCacheKey];
}

- (void)saveFingerprintedDrivers:(BOOL)enabled {
    [RACacheManager cacheBool:enabled forKey:kFingerPrintedOnlyModeCacheKey];
}

@end

#pragma mark - Private

@implementation RARideRequestManager (Private)

- (void)createCurrentRideRequestIfNeeded {
    if (!self.currentRideRequest) {
        self.currentRideRequest = [RARideRequest new];
        self.currentRideRequest.womanOnlyMode = [self isWomanOnlyModeOn];
    }
}

@end

@implementation RARideRequestManager (FemaleDriverModeDataSource)

- (BOOL)isFemaleDriverModeOn {
    if (self.currentRideRequest) {
        return self.currentRideRequest.isWomanOnlyMode;
    } else {
        return self.isWomanOnlyModeOn;
    }
}

@end
