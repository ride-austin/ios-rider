//
//  ConfigTipping.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigTipping : MTLModel <MTLJSONSerializing>
/**
 *  @brief enabled
 */
@property (nonatomic) BOOL enabled;
/**
 *  @brief max tip allowed
 */
@property (nonatomic) NSNumber *tipLimit;

@end
