//
//  RAContactHelper.h
//  Ride
//
//  Created by Roberto Abreu on 11/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAContactHelper : NSObject

+ (NSString * _Nonnull)maskContactNumberWithDirectConnectIfNeeded:(NSString * _Nonnull)contactNumber;
+ (void)performCall:(NSString * _Nonnull)contactNumber;
+ (void)performSMS:(NSString * _Nonnull)contactNumber;

@end
