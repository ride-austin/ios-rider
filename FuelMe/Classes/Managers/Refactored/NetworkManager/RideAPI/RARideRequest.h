//
//  RARideRequest.h
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RARideRequestAbstract.h"

@interface RARideRequest : RARideRequestAbstract

@property (nonatomic, strong) RARideLocationDataModel *endLocation;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, getter=isWomanOnlyMode) BOOL womanOnlyMode;

@end

@interface RARideRequest (Comments)

@property (nonatomic, readonly) NSString *cachedComment;

- (void)storeComment;

@end
