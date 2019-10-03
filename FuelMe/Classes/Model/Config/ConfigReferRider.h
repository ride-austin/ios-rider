//
//  ConfigReferRider.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigReferRider : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic) NSString *tempDetailText;
@property (nonatomic) NSString *tempEmailBody;
@property (nonatomic) NSString *tempSMSBody;
@property (nonatomic) NSString *downloadURL;

@end
