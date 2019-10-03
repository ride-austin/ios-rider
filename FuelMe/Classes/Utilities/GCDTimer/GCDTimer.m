//
//  GCDTimer.m
//  Ride
//
//  Created by Kitos on 11/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#include "GCDTimer.h"

GCDQueue getMainQueue() {
    return dispatch_get_main_queue();
}

GCDQueue getUserInteractiveQueue() {
    return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
}

GCDQueue getUserInitiatedQueue() {
    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
}

GCDQueue getDefaultQueue() {
    return dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
}

GCDQueue getUtilityQueue() {
    return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
}

GCDQueue getBackgroundQueue() {
    return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
}

GCDQueue createCustomQueue(Boolean isConcurrent, char* label) {
    GCDQueue q = dispatch_queue_create( label, (isConcurrent ? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL) );
    return q;
}

GCDQueue createQueue(char* label, Boolean serial, GCDQOS qualityOfService) {
    GCDQueueAttributes queueAttrs = dispatch_queue_attr_make_with_qos_class(
                                                                            (serial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT),
                                                                            qualityOfService,
                                                                            0
                                                                            );
    
    return dispatch_queue_create(label,queueAttrs);
}

GCDTimer createTimer(NSTimeInterval interval, GCDQueue queue, GCDBlock block) {
    GCDTimer timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer,
                                  dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC),
                                  interval * NSEC_PER_SEC,
                                  (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
    }
    
    return timer;
}

void resumeTimer(GCDTimer timer) {
    if (timer) {
        dispatch_resume(timer);
    }
}

void suspendTimer(GCDTimer timer) {
    if (timer) {
        dispatch_suspend(timer);
    }
}

void cancelTimer(GCDTimer timer) {
    if (timer) {
        __block GCDTimer theTimer = timer;
        dispatch_source_set_cancel_handler(timer, ^{
            theTimer = NULL;
        });
        
        dispatch_source_cancel(timer);
    }
}
