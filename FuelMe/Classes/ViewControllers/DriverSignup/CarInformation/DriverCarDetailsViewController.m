//
//  DriverCarDetailsViewController.m
//  Ride
//
//  Created by Abdul Rehman on 16/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarDetailsViewController.h"
#import "Ride-Swift.h"

@interface DriverCarDetailsViewController ()

@property (nonatomic) DSCarIsAddedViewModel *viewModel;
@property (nonatomic, weak) IBOutlet UITextView *tvSubtitle;

@end

@implementation DriverCarDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.carIsAddedViewModel;
    
    self.title = self.viewModel.headerText;
    self.tvSubtitle.text = self.viewModel.subtitle;
    self.tvSubtitle.accessibilityLabel = self.viewModel.subtitle;
    self.tvSubtitle.font = [UIFont fontWithName:FontTypeLight size:14.0];
}

- (IBAction)didTapNext:(UIBarButtonItem *)sender {
    [self.coordinator showNextScreenFromScreen:DSScreenCarIsAdded];
}

@end
