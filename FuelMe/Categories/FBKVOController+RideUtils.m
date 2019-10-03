//
//  FBKVOController+RideUtils.m
//  Ride
//
//  Created by Roberto Abreu on 12/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "FBKVOController+RideUtils.h"

@implementation FBKVOController (RideUtils)

- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths handler:(RAKVObserveBlock)handler {
    [self observe:object keyPaths:keyPaths options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            if(handler){
                handler(observer,change);
            }
        }
     ];
}

@end
