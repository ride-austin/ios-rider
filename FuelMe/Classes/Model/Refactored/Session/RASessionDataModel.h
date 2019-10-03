//
//  RASession.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RARiderDataModel.h"

@interface RASessionDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) RARiderDataModel *rider; //not returned by RASessionAPI

@end
