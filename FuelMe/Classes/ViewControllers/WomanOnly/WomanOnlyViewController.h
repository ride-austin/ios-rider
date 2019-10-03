//
//  WomanOnlyViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 10/22/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@protocol WomanOnlyViewDelegate

- (void)womanOnlyModeChanged;

@end

@interface WomanOnlyViewController : BaseViewController

@property (nonatomic) id <WomanOnlyViewDelegate> delegate;

@end
