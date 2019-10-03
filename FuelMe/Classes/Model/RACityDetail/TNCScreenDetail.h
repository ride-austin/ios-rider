//
//  TNCScreenDetail.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TNCScreenDetail : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL needsBackPhoto; //readwrite for unit test
@property (nonatomic) BOOL isEnabled; //readwrite for unit test
@property (nonatomic, readonly) NSString *actionText1;
@property (nonatomic, readonly) NSString *headerText;
@property (nonatomic, readonly) NSString *text1;
@property (nonatomic, readonly) NSString *title1;

@property (nonatomic, readonly) NSString *text2;
@property (nonatomic, readonly) NSString *title2;

@property (nonatomic, readonly) NSString *title1Back;
@property (nonatomic, readonly) NSString *text1Back;

@end
