//
//  RATokensAPI.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"

@interface RATokensAPI : RABaseAPI

+ (void)postToken:(NSString * _Nonnull)token withCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;

@end
