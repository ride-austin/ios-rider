//
//  RARideUserDataModel.h
//  RideAustin
//
//  Created by Kitos on 2/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAUserDataModel.h"

@interface RARideUserDataModel : RAUserDataModel

@property (nonatomic, strong) NSNumber *rating;
- (NSString *)displayRating;

@end
