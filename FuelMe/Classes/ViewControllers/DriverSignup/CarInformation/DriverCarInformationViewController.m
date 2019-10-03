//
//  DriverCarInformationViewController.m
//  Ride
//
//  Created by Roberto Abreu on 17/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DSViewModel.h"
#import "DriverCarInformationViewController.h"
#import "Ride-Swift.h"
#import "VehicleInformationHeaderTableViewCell.h"
#import "VehicleInformationRequirementTableViewCell.h"

@interface DriverCarInformationViewController () <UITableViewDataSource>

@property (nonatomic) DSCarInfoViewModel *viewModel;

@end

@implementation DriverCarInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
    [self configureTable];
    [self configureRegistrationConfig];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.carInfoViewModel;
    self.title = self.viewModel.headerText;
}

- (void)configureTable {
    self.tblVehicleInformation.estimatedRowHeight = 44;
    self.tblVehicleInformation.rowHeight = UITableViewAutomaticDimension;
    [self.tblVehicleInformation setNeedsLayout];
    [self.tblVehicleInformation layoutIfNeeded];
}

- (void)configureRegistrationConfig {
    [self.tblVehicleInformation reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        self.vContainer.alpha = 1.0;
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.requirements.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        
        //Header Information
        VehicleInformationHeaderTableViewCell *cell = (VehicleInformationHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:VehicleInformationHeaderTableViewCell.className forIndexPath:indexPath];
       
        cell.lblDescription.text = self.viewModel.cityDescription;
        cell.lblDescription.font = [UIFont fontWithName:FontTypeLight size:14.0];
        cell.lblDescription.accessibilityLabel = self.viewModel.cityDescription;
    
        return cell;
        
    } else {
        
        //Requirements
        NSString *requirement = self.viewModel.requirements[indexPath.row - 1];
        VehicleInformationRequirementTableViewCell *cell = (VehicleInformationRequirementTableViewCell*)[tableView dequeueReusableCellWithIdentifier:VehicleInformationRequirementTableViewCell.className forIndexPath:indexPath];
        cell.lblRequirement.text = requirement;
        cell.lblRequirement.accessibilityLabel = requirement;
        return cell;
    }
}

- (IBAction)handleTapContinue:(UIButton *)sender {
    [self.coordinator showNextScreenFromScreen:DSScreenCarInfo];
}

@end
