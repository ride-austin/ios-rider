//
//  RAActiveDriversManager.m
//  Ride
//
//  Created by Kitos on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAActiveDriversManager.h"
#import "RAActiveDriversAPI.h"
#import "RAActiveDriversPolling.h"
#import "RideConstants.h"

@interface RAActiveDriversManager ()

@property (nonatomic, getter=isPolling) BOOL polling;
@property (nonatomic, strong) RAActiveDriversRequest *request;
@property (nonatomic, strong) RAActiveDriversPolling *acdrPolling;
@property (nonatomic, copy) RAActiveDriversBlock callback;

@end

@implementation RAActiveDriversManager

+ (RAActiveDriversManager *)sharedManager {
    static RAActiveDriversManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [RAActiveDriversManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.polling = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPolling) name:kDidSignoutNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startPollingWithRequest:(RAActiveDriversRequest *)request andCompletion:(RAActiveDriversBlock)callback {
    [self stopPolling];
    self.callback = callback;
    [self updateRequest:request];
    
    __weak RAActiveDriversManager *weakSelf = self;
    self.acdrPolling = [[RAActiveDriversPolling alloc] initWithDispatchBlock:^{
        RAActiveDriversRequest *activeDriverRequest = [weakSelf.request copy];
        [RAActiveDriversAPI getActiveDrivers:activeDriverRequest withCompletion:callback];
    }];
    
    [self.acdrPolling resume];
    self.polling = YES;
}

- (void)stopPolling {
    [self.acdrPolling pause];
    self.acdrPolling = nil;
    self.polling = NO;
    self.callback = NULL;
}

- (void)updateRequest:(RAActiveDriversRequest *)request {
    self.request = request;
    [RAActiveDriversAPI getActiveDrivers:self.request withCompletion:self.callback];//launch first dispatch immediately
}

@end
