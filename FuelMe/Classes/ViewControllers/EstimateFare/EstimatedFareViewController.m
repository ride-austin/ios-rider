//
//  EstimatedFareViewController.m
//  Ride
//
//  Created by Abdul Rehman on 21/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "EstimatedFareViewController.h"

#import "NSString+Utils.h"

@interface EstimatedFareViewController()

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *lblStartAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDestinationAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblEstimate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@end

@implementation EstimatedFareViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureAccessibility];
}

#pragma mark - Configure UI

- (void)configureUI {
    self.title = self.viewModel.title;
    self.lblStartAddress.text = self.viewModel.startAddress;
    self.lblDestinationAddress.text = self.viewModel.endAddress;
    self.lblEstimate.text = self.viewModel.displayFareEstimate;
    self.navigationItem.leftBarButtonItem = self.btnCancel;
}

- (void)configureAccessibility {
    self.btnCancel.accessibilityLabel = [@"Back" localized];
    self.view.accessibilityIdentifier = @"EstimateFareView";
    self.lblEstimate.accessibilityIdentifier = @"EstimateLabel";
}

#pragma mark - IBActions

- (IBAction)btnClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnEnterANewLocationPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(estimatedViewChangedDestinationPressed)]) {
            [self.delegate estimatedViewChangedDestinationPressed];
        }
    }];
}

@end
