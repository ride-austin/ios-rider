//
//  RADriverDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RACarDataModel.h"
#import "RARideUserDataModel.h"

@interface RADriverDataModel : RARideUserDataModel

@property (nonatomic, strong) RAUserDataModel *user;
@property (nonatomic, strong) NSArray<RACarDataModel*> *cars;

//used when registering
@property (nonatomic, strong) UIImage *licensePhoto;
@property (nonatomic, strong) UIImage *insurancePhoto;

@property (nonatomic, readonly) BOOL isDeaf;

@end
