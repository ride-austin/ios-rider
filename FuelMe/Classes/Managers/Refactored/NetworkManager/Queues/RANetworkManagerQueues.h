//
//  RANetworkManagerQueues.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//
/*
 *  most of the time, request should be in a concurrent queue, and the mapping is in another concurrent queue. But for cases where the completion is updating non-thread safe objects, please create a serial queue
 *
 */

// Use unique identifer to create a serial queue otherwise the other types below will get a concurrent global queue with QOS_CLASS

// get main queue
extern NSString * const QueueTypeMainQueue;
// get concurrent global queue with QOS_CLASS_USER_INTERACTIVE
extern NSString * const QueueTypeUserInteractive;
// get concurrent global queue with QOS_CLASS_USER_INITIATED
extern NSString * const QueueTypeUserInitiated;
// get concurrent global queue with QOS_CLASS_UTILITY
extern NSString * const QueueTypeUtility;
// get concurrent global queue with QOS_CLASS_BACKGROUND
extern NSString * const QueueTypeBackground;
// get concurrent global queue with QOS_CLASS_DEFAULT
extern NSString * const QueueTypeDefault;


/**
 *
 *
 QOS_CLASS reference http://nshipster.com/nsoperation/

 .userInteractive: User-interactive QoS is used for work directly involved in providing an interactive UI such as processing events or drawing to the screen.
 
 .userInitiated: User-initiated QoS is used for performing work that has been explicitly requested by the user and for which results must be immediately presented in order to allow for further user interaction. For example, loading an email after a user has selected it in a message list.
 
 .utility: Utility QoS is used for performing work which the user is unlikely to be immediately waiting for the results. This work may have been requested by the user or initiated automatically, does not prevent the user from further interaction, often operates at user-visible timescales and may have its progress indicated to the user by a non-modal progress indicator. This work will run in an energy-efficient manner, in deference to higher QoS work when resources are constrained. For example, periodic content updates or bulk file operations such as media import.
 
 .background: Background QoS is used for work that is not user initiated or visible. In general, a user is unaware that this work is even happening and it will run in the most efficient manner while giving the most deference to higher QoS work. For example, pre-fetching content, search indexing, backups, and syncing of data with external systems.
 
 .default: Default QoS indicates the absence of QoS information. Whenever possible QoS information will be inferred from other sources. If such inference is not possible, a QoS between UserInitiated and Utility will be used.

 *
 */
