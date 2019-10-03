//
//  FakeLaunchViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@protocol FakeLaunchProtocol 

- (void)didFinishLaunching;

@end

@interface FakeLaunchViewController : BaseViewController

@property (nonatomic, weak) id<FakeLaunchProtocol> _Nullable delegate;
- (instancetype _Nonnull)initWithLaunchOptions:(NSDictionary * _Nullable)launchOptions;

@end
