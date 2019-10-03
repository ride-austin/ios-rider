//
//  RAEventParameters.h
//  Ride
//
//  Created by Theodore Gonzalez on 10/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RASurgeAreaDataModel.h"

@interface RAEventParameters : RASurgeAreaDataModel

@property (nonatomic, readonly) NSArray<RASurgeAreaDataModel *> *surgeAreas;

@end
