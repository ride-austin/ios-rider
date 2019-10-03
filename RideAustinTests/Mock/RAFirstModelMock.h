//
//  RAFirstModelMock.h
//  Ride
//
//  Created by Roberto Abreu on 22/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RABaseDataModel.h"

@interface RAFirstModelMock : RABaseDataModel

@property (nonatomic) NSString *sampleProp;
@property (nonatomic) NSString *anExcludeProp;
@property (nonatomic) BOOL didFinishUpdating;
@property (nonatomic) BOOL didPerformCustomUpdate;
@property (nonatomic) BOOL didStartUpdatingWithModel;
@property (nonatomic) BOOL didPropertyUpdated;

@end
