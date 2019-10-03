//
//  SplitResponse.h
//  Ride
//
//  Created by Abdul Rehman on 04/11/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplitResponse : NSObject

@property (nonatomic,strong) NSString * splitID;
@property (nonatomic,assign) BOOL accepted;

- (instancetype)initWithSplitID:(NSString*)splitID andResponse:(BOOL)response;

@end
