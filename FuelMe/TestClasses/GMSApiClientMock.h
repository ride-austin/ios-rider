//
//  GMSApiClientMock.h
//  Ride
//
//  Created by Roberto Abreu on 6/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSApiClientMock : NSObject

+ (instancetype)sharedInstance;

- (void)addMapQuery:(NSString*)query toResponseFile:(NSString*)fileNames;
- (void)addMapRegexQuery:(NSString*)regQuery toResponseFile:(NSString*)fileName;
- (NSDictionary*)predictionsWithQuery:(NSString*)query;

@end
