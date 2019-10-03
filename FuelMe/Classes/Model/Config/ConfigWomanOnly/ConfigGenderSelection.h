//
//  ConfigGenderSelection.h
//  Ride
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigGenderSelection : RABaseDataModel

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSArray<NSString *> *options;

@end
