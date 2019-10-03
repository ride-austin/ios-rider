//
//  ConfigUT.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigUTPayWithBevoBucks.h"
#import "RABaseDataModel.h"

@interface ConfigUT : RABaseDataModel

@property (nonatomic, readonly, nonnull, copy) ConfigUTPayWithBevoBucks *payWithBevoBucks;

@end
