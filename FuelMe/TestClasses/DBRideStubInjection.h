//
//  DBRideStubInjection.h
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockRideResponseModel.h"

#pragma mark - Ride Stub Injection

typedef  NS_ENUM(NSUInteger, DBRideInjectionType){
    DBRITRideChildObject = 0,
    DBRITNoNetwork = 1
};

@interface DBRideStubInjection : NSObject

@property (nonatomic) DBRideInjectionType injectionType;
@property (nonatomic) MockRideStatus injectAfterStatus;
@property (nonatomic) NSUInteger delay;
@property (nonatomic) NSUInteger totalDelay;
@property (nonatomic) NSInteger timeout; // MNegative value meams it is kept all time. (curently it is used only for NoNetwork type)
@property (nonatomic) NSString *injectJSONFile;
@property (nonatomic, readonly) NSDictionary *jsonDict;

@end
