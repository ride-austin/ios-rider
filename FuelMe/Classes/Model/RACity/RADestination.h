//
//  RADestination.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RADestination : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *placeDescription;
@property (nonatomic) NSString *primaryAddress;
@property (nonatomic) NSString *googleReference;
@property (nonatomic) NSString *secondaryAddress;

+ (instancetype)austinAirport;

- (BOOL)didMatchString:(NSString *)searchString;
- (BOOL)didMatchGoogleId:(NSString *)googleId;

@end
