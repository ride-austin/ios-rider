//
//  RACharityDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RACharityDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *charityDescription;
@property (nonatomic, strong) NSURL *imageURL;

@end
