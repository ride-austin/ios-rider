//
//  ModelViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "ModelViewController.h"
#import "Ride-Swift.h"

#define modelsURI (@"/api/vehicle/modelrepository/findmodelsbymakeandyear")

@interface ModelViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *modelsData;

@end

@implementation ModelViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Model";
    [self configureModelData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureModelData {
    RACarManager *carManager = self.coordinator.regConfig.carManager;
    self.modelsData = [carManager getModelsWithOrder:YES withMake:self.car.make andYear:self.car.year];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (DSCar *)car {
    return self.coordinator.car;
}

#pragma mark - UITableView Datasource & Delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@", self.car.year, self.car.make];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelsData count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"ModelViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    
    NSString *model = [self.modelsData objectAtIndex:indexPath.row];
    cell.textLabel.text = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.car.model = self.modelsData[indexPath.row];
    [self.coordinator showNextScreenFromScreen:DSScreenCarModel];
}

@end
