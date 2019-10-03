//
//  RAPollingManager.h
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDTimer.h"

@protocol RAPollingProtocol <NSObject>

- (instancetype)initWithDispatchBlock:(GCDBlock)callback;

@end

@interface RAPollingManager : NSObject <RAPollingProtocol>

@property (nonatomic, readonly) BOOL isExecuting;

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval andExecutionBlock:(GCDBlock)callback;
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval queue:(GCDQueue)queue andExecutionBlock:(GCDBlock)callback;
- (void)resume;
- (void)pause;

@end
