//
//  SplitFareManager.m
//  Ride
//
//  Created by Abdul Rehman on 03/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SplitFareManager.h"

#import "ErrorReporter.h"
#import "NSNotificationCenterConstants.h"
#import "PersistenceManager.h"
#import "RAMacros.h"
#import "RASplitFarePolling.h"
#import "RideConstants.h"
#import "SplitFareAPI.h"
#import "RAAlertManager.h"

#define userKey(x) [self appendUserToKey:x]
#define defaults [NSUserDefaults standardUserDefaults]

NSString *const kSplitID        = @"kSplitID";
NSString *const kSplitResponse  = @"kSplitResponse";

@interface SplitFareManager()

@property (nonatomic, strong) RASplitFarePolling *splitFarePolling;
@property (nonatomic) NSMutableArray *arraySections;

@end

@implementation SplitFareManager

#pragma mark - Lifecycle

+ (SplitFareManager *)sharedManager{
    static SplitFareManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SplitFareManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.arraySections     = [NSMutableArray new];
        self.contactsAccepted  = [NSMutableArray new];
        self.contactsDeclined  = [NSMutableArray new];
        self.contactsRequested = [NSMutableArray new];
        self.pendingRequests   = [NSMutableArray new];
        [self addObservers];
    }
    return self;
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPolling) name:kDidSignoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(targetUserAcceptedSplitFare:) name:kNotificationSplitFareAccepted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(targetUserDeclinedSplitFare:) name:kNotificationSplitFareDeclined object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSplitFareRequest:) name:kNotificationSplitFareRequested object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<SplitFarePushDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        [self checkMissedSplitFareRequests];
    }
}

#pragma mark -

- (void)reloadDataWithRideId:(NSString*)rideID andCompletion:(void(^)(NSError *error, BOOL stopPolling))block {
    if (!rideID || [rideID isKindOfClass:[NSNull class]]) {
        NSError *error = [NSError errorWithDomain:@"noRideID" code:-1 userInfo:nil];
        block(error, YES);
        return;
    }
    
    __weak SplitFareManager *weakSelf = self;
    [SplitFareAPI getListOfSplitsByRideID:rideID andCompletion:^(NSArray<SplitFare *> *splitFares, NSError *error) {
        if (error) {
            //Note: Error code 403 ~ when ride is completed, cancelled or user is not part of ride
            BOOL hasNoSplits = error.code == 403;
            if (hasNoSplits) {
                [weakSelf configureData:@[]];
                block(nil, YES);
            } else {
                block(error, NO);
            }
        } else {
            [weakSelf configureData:splitFares];
            block(nil, NO);
        }
    }];
}

- (void)sendSplitRequestToContact:(Contact*)contact inRide:(NSString*)rideID withCompletion:(void(^)(id responseObject,NSError *error))completion {
    [SplitFareAPI sendSplitFareRequestsToPhoneNumbers:contact.phoneNumbers inRide:rideID andCompletion:completion];
}

- (void)respondToSplitRequestWithSPlitResponse:(SplitResponse*)response {
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        [PersistenceManager cacheResponseForSplitInvitationWithResponse:response];
    } else {
        [SplitFareAPI respondToSplitFareRequestForSplitID:response.splitID withAcceptance:response.accepted andCompletion:^(id responseObject, NSError *error) {
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            }
        }];
    }
}

- (void)removeSplitWithSplitID:(NSString*)splitID andCompletion:(void(^)(BOOL))completion {
    [SplitFareAPI removeSplitByID:splitID andCompletion:^(NSError *error) {
        if (!error) {
            [RAAlertManager showAlertWithTitle:@"Split fare" message:@"Split removed successfully"];
        }
        completion(error == nil);
    }];
}

#pragma mark- Cache management

- (void)checkCachedSplitResponseAndUpdate {
    if ([PersistenceManager hasSplitFareResponseCached]) {
        SplitResponse * response = [PersistenceManager getCachedResponse];
        [SplitFareAPI respondToSplitFareRequestForSplitID:response.splitID withAcceptance:response.accepted andCompletion:^(id responseObject, NSError *error) {
            if (!error) {
                [PersistenceManager removeResponseFromArray:response];
                [self checkCachedSplitResponseAndUpdate];
            } else {
                [ErrorReporter recordError:error withDomainName:POSTSplitFareRespond];
                DBLog(@"respondingToSplitFareRequestCache error: %@", error);
            }
        }];
    }
}

#pragma mark - dataSource

- (void)configureData:(NSArray<SplitFare*>*)splitFares {
    [self.arraySections removeAllObjects];
    [self.contactsAccepted  removeAllObjects];
    [self.contactsDeclined  removeAllObjects];
    [self.contactsRequested removeAllObjects];
    
    for (SplitFare *splitFare in splitFares) {
        switch (splitFare.status) {
            case SFStatusRequested:
                [self.contactsRequested addObject:splitFare];
                break;
            case SFStatusAccepted:
                [self.contactsAccepted addObject:splitFare];
                break;
            case SFStatusDeclined:
                [self.contactsDeclined addObject:splitFare];
                break;
            case SFStatusInvalid:
                break;
        }
    }
    
    if (self.contactsAccepted.count  > 0) {
        NSString *title = [NSString stringWithFormat:@"FARE SPLITTING %ld WAYS", self.contactsAccepted.count + 1];
        [self.arraySections addObject:@[title, self.contactsAccepted]];
    }
    
    if (self.contactsDeclined.count  > 0) {
        [self.arraySections addObject:@[@"NOT SPLITTING", self.contactsDeclined]];
    }
    
    if (self.contactsRequested.count > 0) {
        [self.arraySections addObject:@[@"PENDING REQUESTS", self.contactsRequested]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSplitFareDataUpdated object:nil];
}

- (NSInteger)totalContacts {
    return self.contactsAccepted.count + self.contactsDeclined.count + self.contactsRequested.count;
}

- (NSUInteger)numberOfsections {
    return self.arraySections.count;
}

- (NSUInteger)numberOfRowsForSection:(NSUInteger)section {
    return [[self.arraySections[section] lastObject] count];
}

- (NSString *)titleOfHeaderInSection:(NSUInteger)section {
    return [self.arraySections[section] firstObject];
}

- (SplitFare *)contactForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *contacts = [self.arraySections[indexPath.section] lastObject];
    return contacts[indexPath.row];
}

#pragma mark - Notification Center Handlers

- (void)targetUserAcceptedSplitFare:(NSNotification*)notification {
    Contact *contact = (Contact*)notification.object;
    NSAssert(self.delegate, @"targetUserAcceptedSplitFare is called without delegate");
    if (self.delegate) {
        [self.delegate splitFarePushAcceptedFromContact:contact];
    }
}

- (void)targetUserDeclinedSplitFare:(NSNotification*)notification {
    Contact *contact = (Contact*)notification.object;
    NSAssert(self.delegate, @"targetUserDeclinedSplitFare is called without delegate");
    if (self.delegate) {
        [self.delegate splitFarePushRejectedFromContact:contact];
    }
}

- (void)didReceiveSplitFareRequest:(NSNotification*)notification {
    [self checkMissedSplitFareRequests];
}

- (void)checkMissedSplitFareRequests {
    [self.pendingRequests removeAllObjects];
    __weak SplitFareManager *weakSelf = self;
    [SplitFareAPI getPendingSplitRequestsForCurrentRiderWithCompletion:^(NSArray<SplitFare *> *splitFares, NSError *error) {
        if (!error && splitFares.count > 0) {
            weakSelf.pendingRequests = [NSMutableArray arrayWithArray:splitFares];
            SplitFare *splitFare = [weakSelf.pendingRequests lastObject];
            if (![PersistenceManager hasSplitResponseCachedWithSplitId:splitFare.modelID.stringValue]) {
                Contact *contact = [[Contact alloc] initWithSourceSplitFare:splitFare];
                NSAssert(self.delegate, @"checkMissedSplitFareRequests is called without delegate");
                if (self.delegate) {
                    [self.delegate splitFarePushRequestedWithId:splitFare.modelID.stringValue rideId:splitFare.rideID.stringValue fromContact:contact];
                }
            }
        }
    }];
}

@end

#pragma mark - Polling

#import "RARideManager.h"

@implementation SplitFareManager (Polling)

- (void)startPolling {
    [self startPollingWithReloadCompletion:nil];
}

- (void)startPollingWithReloadCompletion:(RASplitFareReloadBlock)handler {
    [self stopPolling];

    if ([[RARideManager sharedManager] isRiding]) {
        
        NSString *rideID = [[[[RARideManager sharedManager] currentRide] modelID] stringValue];
        
        if (rideID) {

            __weak SplitFareManager *weakSelf = self;
            self.splitFarePolling = [[RASplitFarePolling alloc] initWithDispatchBlock:^{
                [weakSelf reloadDataWithRideId:rideID andCompletion:^(NSError *error, BOOL stopPolling) {
                    if (stopPolling) {
                        [weakSelf stopPolling];
                    }
                    if (handler) {
                        handler(error);
                    }

                }];
            }];
            
            [weakSelf reloadDataWithRideId:rideID andCompletion:^(NSError *error, BOOL stopPolling) {
                if (stopPolling) {
                    [weakSelf stopPolling];
                }
                if (handler) {
                    handler(error);
                }

            }]; //launch first dispatch immediately
            
            [self.splitFarePolling resume];
        }
        
    }
}

- (void)stopPolling{
    [self.splitFarePolling pause];
    self.splitFarePolling = nil;
}

@end
