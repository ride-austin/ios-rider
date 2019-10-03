//
//  RANetworkManager.h
//  RideDriver
//
//  Created by Carlos Alcala on 8/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SystemConfiguration/SystemConfiguration.h>

#import "RAMultipartRequest.h"
#import "RARequest.h"

#import <AFNetworking/AFNetworking.h>

@interface RANetworkManager : NSObject

@property(nonatomic, strong) NSString* baseURL;
@property(nonatomic, strong) NSString* authToken;
@property(nonatomic, readonly) BOOL isAuthenticated;

+ (RANetworkManager*)sharedManager;

- (void) reloadBaseURL; //Used when environment is changed (only on test mode)
- (void) cancelAllOperations;

@end

@interface RANetworkManager (Requests)
-(void)executeRequest:(RARequest*)request;
@end

typedef NS_ENUM(NSInteger, RANetworkReachability) {
    RANetworkNotReachable = 0,
    RANetworkReachable = 1
};

typedef void(^RANetworkReachabilityBlock)(RANetworkReachability networkReachability);

typedef NS_ENUM(NSUInteger, RANetworkStatusSimulation){
    RASimNetUnreachableStatus = 0
};

@interface RANetworkManager (Reachability)

@property(nonatomic, readonly) BOOL isNetworkReachable;

-(void)addReachabilityObserver:(NSObject*)observer statusChangedBlock:(RANetworkReachabilityBlock)handler;
-(void)removeReachabilityObserver:(NSObject*)observer;


//Only for UITesting
-(void)simulateNetworkStatus:(RANetworkStatusSimulation)networkStatus;
-(void)disableNetworkStatusSimualation;

@end
