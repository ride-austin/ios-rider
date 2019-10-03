//
//  RASecondModelMock.h
//  Ride
//
//  Created by Roberto Abreu on 22/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RABaseDataModel.h"
#import "RAFirstModelMock.h"

@interface RASecondModelMock : RABaseDataModel

@property (nonatomic) RAFirstModelMock *firstModel;

@end
