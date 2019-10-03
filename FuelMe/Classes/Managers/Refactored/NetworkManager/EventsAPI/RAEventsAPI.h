//
//  RAEventsAPI.h
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"
#import "RAEventDataModel.h"

typedef void(^RAEventsCopmletionBlock)(NSArray<RAEventDataModel*> *events, NSError *error);

@interface RAEventsAPI : RABaseAPI

+ (void)getEventsWithLastReceivedEvent:(NSString*)eventID copmletion:(RAEventsCopmletionBlock)handler;

@end
