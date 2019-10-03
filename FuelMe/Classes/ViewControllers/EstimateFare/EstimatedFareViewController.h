//
//  EstimatedFareViewController.h
//  Ride
//
//  Created by Abdul Rehman on 21/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"
#import "RAEstimatedFareViewModel.h"

@protocol EstimatedFareViewDelegate <NSObject>

- (void)estimatedViewChangedDestinationPressed;

@end

@interface EstimatedFareViewController : BaseViewController

//Properties
@property (weak) id <EstimatedFareViewDelegate> delegate;
@property (strong, nonatomic) RAEstimatedFareViewModel *viewModel;

@end
