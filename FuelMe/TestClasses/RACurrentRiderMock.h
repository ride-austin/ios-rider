//
//  RACurrentRiderMock.h
//  Ride
//
//  Created by Roberto Abreu on 5/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARiderDataModel.h"

@interface RACurrentRiderMock : RARiderDataModel

+ (instancetype)sharedInstance;

- (void)updateWithRiderMockModel:(RACurrentRiderMock*)riderMock;

@end
