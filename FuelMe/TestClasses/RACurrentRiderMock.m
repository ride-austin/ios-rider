//
//  RACurrentRiderMock.m
//  Ride
//
//  Created by Roberto Abreu on 5/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACurrentRiderMock.h"
#import "NSDictionary+JSON.h"
#import "RACardManagerMock.h"

static NSString *kIncludeUnpaidKeyInCurrentRider  = @"kIncludeUnpaidKeyInCurrentRider";
static NSString *kExcludeCharityKeyInCurrentRider = @"kExcludeCharityKeyInCurrentRider";

@implementation RACurrentRiderMock

+ (instancetype)sharedInstance {
    static RACurrentRiderMock *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CURRENT_RIDER_200" ofType:@"json"];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
        sharedInstance = [MTLJSONAdapter modelOfClass:[RACurrentRiderMock class] fromJSONDictionary:jsonDict error:nil];
        
        //Configure Instance
        NSArray<NSString*> *arguments = [[NSProcessInfo processInfo] arguments];
        
        if ([arguments containsObject:kExcludeCharityKeyInCurrentRider]) {
            sharedInstance.charity = nil;
        }
        
        sharedInstance.cards = [RACardManagerMock sharedInstance].cards;
        
        sharedInstance.unpaidBalance = nil;
    });
    return sharedInstance;
}

- (void)updateWithRiderMockModel:(RACurrentRiderMock *)riderMock {
    self.charity = riderMock.charity;
    self.type = riderMock.type;
    self.user = riderMock.user;
}

@end
