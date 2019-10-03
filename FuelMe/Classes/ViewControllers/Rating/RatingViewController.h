//
//  RatingViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/30/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@class RatingViewModel;

typedef void(^RatingSelectionBlock)(CGFloat rating);

@interface RatingViewController : BaseViewController

@property (nonatomic) RatingViewModel *viewModel;
@property (nonatomic, copy) RatingSelectionBlock ratingSelectedBlock;

@end
