//
//  FBKVOController+RideUtils.h
//  Ride
//
//  Created by Roberto Abreu on 12/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <KVOController/KVOController.h>

typedef void(^RAKVObserveBlock)(FBKVOController *_Nonnull observer, NSDictionary<NSString*,id> *_Nonnull change);

@interface FBKVOController (RideUtils)

- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *_Nonnull)keyPaths handler:(RAKVObserveBlock _Nonnull )handler;

@end
