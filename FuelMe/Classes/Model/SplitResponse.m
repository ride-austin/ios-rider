//
//  SplitResponse.m
//  Ride
//
//  Created by Abdul Rehman on 04/11/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SplitResponse.h"

static NSString *const kSplitID                 = @"kSplitID";
static NSString *const kSPlitResponse           = @"kSPlitResponse";

@implementation SplitResponse

- (instancetype)initWithSplitID:(NSString*)splitID andResponse:(BOOL)response {
    self = [super init];
    if (self) {
        self.splitID=splitID;
        self.accepted=response;
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.splitID= [aDecoder decodeObjectForKey:kSplitID];
        self.accepted = [aDecoder decodeBoolForKey:kSPlitResponse];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.splitID   forKey:kSplitID];
    [aCoder encodeBool:self.accepted forKey:kSPlitResponse];
}

@end
