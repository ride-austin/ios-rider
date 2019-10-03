//
//  RAEventsAPI.m
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAEventsAPI.h"

static NSString *const kAvatarField = @"avatarType";
static NSString *const kLastReceivedEventField = @"lastReceivedEvent";

@implementation RAEventsAPI

+ (void)getEventsWithLastReceivedEvent:(NSString *)eventID copmletion:(RAEventsCopmletionBlock)handler{
    NSString *path = [NSString stringWithFormat:@"%@?%@=RIDER",kPathEvents,kAvatarField];
    if (eventID) {
        path = [path stringByAppendingFormat:@"&%@=%@",kLastReceivedEventField,eventID];
    }
    
    [[RARequest requestWithPath:path success:^(NSURLSessionTask *networkTask, id response) {
        NSArray <RAEventDataModel*> *events = [RAJSONAdapter modelsOfClass:RAEventDataModel.class fromJSONArray:response isNullable:YES];
        if (handler) {
            handler(events, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil,error);
        }
    }] execute];
}

@end
