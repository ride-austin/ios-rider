//
//  RABaseAPI.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ErrorReporter.h"
#import "NSObject+QueueName.h"
#import "RAJSONAdapter.h"
#import "RANetworkManager.h"
#import "RANetworkManagerQueues.h"
#import "URLFactory.h"

#import <SDWebImage/SDWebImagePrefetcher.h>

typedef void (^APIResponseBlock)(id responseObject, NSError* error);
typedef void (^APICheckResponseBlock)(BOOL failed, NSError* error);
typedef void (^APIErrorResponseBlock)(NSError* error);

@interface RABaseAPI : NSObject

@end
