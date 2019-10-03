//
//  GCDTimer.h
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#ifndef __RideAustin__TGTimer__
#define __RideAustin__TGTimer__

#include <Foundation/Foundation.h>

typedef dispatch_source_t GCDTimer;
typedef dispatch_queue_t GCDQueue;
typedef dispatch_block_t GCDBlock;
typedef dispatch_queue_attr_t GCDQueueAttributes;
typedef qos_class_t GCDQOS;

GCDQueue getMainQueue(void);
GCDQueue getUserInteractiveQueue(void);
GCDQueue getUserInitiatedQueue(void);
GCDQueue getDefaultQueue(void);
GCDQueue getUtilityQueue(void);
GCDQueue getBackgroundQueue(void);
GCDQueue createCustomQueue(Boolean isConcurrent, char* label);
GCDQueue createQueue(char* label, Boolean serial, GCDQOS qualityOfService);

// Create timer using GCD
GCDTimer createTimer(NSTimeInterval interval, GCDQueue queue, GCDBlock block);

void resumeTimer(GCDTimer timer);
void suspendTimer(GCDTimer timer);

// Stop and release timer created with GCD
void cancelTimer(GCDTimer timer);

#endif /* defined(__RideAustin__TGTimer__) */
