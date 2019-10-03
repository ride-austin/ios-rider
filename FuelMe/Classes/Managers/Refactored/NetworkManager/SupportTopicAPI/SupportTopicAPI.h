//
//  SupportTopicAPI.h
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LIOptionDataModel.h"
#import "RABaseAPI.h"
#import "SupportTopic.h"

typedef void(^SupportTopicBlock)(NSArray<SupportTopic*>* _Nullable supportTopics,NSError * _Nullable error);
typedef void(^SupportTopicPostMessageBlock)(NSError* _Nullable error);
typedef void(^LostAndFoundBlock)(NSString * _Nullable message, NSError * _Nullable error);

@interface SupportTopicAPI : RABaseAPI
+ (void)getSupportTopicListWithCompletion:(SupportTopicBlock _Nonnull )handler;
+ (void)getTopicsWithParentId:(NSNumber*_Nonnull)parentTopicId withCompletion:(SupportTopicBlock _Nonnull )handler;
+ (void)getFormForTopic:(SupportTopic *_Nonnull)topic
         withCompletion:(void(^_Nonnull)(LIOptionDataModel *_Nullable, NSError *_Nullable))completion;
+ (void)postSupportMessage:(NSString*_Nonnull)comment supportTopic:(SupportTopic*_Nonnull)supportTopic rideId:(NSNumber*_Nonnull)rideId withCompletion:(SupportTopicPostMessageBlock _Nonnull )handler;
+ (void)postSupportMessage:(NSString*_Nonnull)message rideID:(NSString *_Nullable)rideID cityID:(NSNumber *_Nullable)cityID withCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;

#pragma mark - Lost Items
#pragma mark Rider
+ (void)postLostAndFoundLostParameters:(NSDictionary *_Nonnull)params
                        withCompletion:(LostAndFoundBlock _Nonnull )completion;
+ (void)postLostAndFoundContactParameters:(NSDictionary *_Nonnull)params
                           withCompletion:(LostAndFoundBlock _Nonnull)completion;
#pragma mark Driver
+ (void)postLostAndFoundFoundParameters:(NSDictionary *_Nonnull)params
                              andImages:(NSDictionary<NSString *, NSData *> *_Nullable)images
                         withCompletion:(LostAndFoundBlock _Nonnull)completion;

@end
