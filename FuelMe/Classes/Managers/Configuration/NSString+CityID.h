//
//  NSString+CityID.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppendType) {
    AppendAsFirstParameter,
    AppendAsLastParameter
};

@interface NSString (CityID)

- (NSString *)pathWithCityAppendType:(AppendType)type;

@end
