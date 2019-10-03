//
//  RAAvatarDataModel.h
//  RideAustin
//
//  Created by Kitos on 30/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger, RAAvatarType) {
    RAAvatarUnknown = 0,
    RAAvatarRider   = 1,
    RAAvatarDriver  = 2,
    RAAvatarAdmin   = 3
};

@interface RAAvatarDataModel : RABaseDataModel

@property (nonatomic, strong) NSNumber *active;
@property (nonatomic) NSString *typeString;

- (RAAvatarType)type;

@end
