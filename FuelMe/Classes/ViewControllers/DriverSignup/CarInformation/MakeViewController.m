//
//  MakeViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "MakeViewController.h"
#import "Ride-Swift.h"

@interface MakeViewController () <UITableViewDataSource, UITableViewDelegate>

//IBOutlets
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* makesData;

@end

@implementation MakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMakesData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureMakesData {
    ConfigRegistration *regConfig = self.coordinator.regConfig;
    self.makesData = [regConfig.carManager getMakesWithOrder:YES andYear:self.year];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSString *)year {
    return self.coordinator.car.year;
}

#pragma mark - UITableView Datasource & Delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.year;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.makesData count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"MakeViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    
    NSString *make = self.makesData[indexPath.row];
    cell.textLabel.text = make;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.coordinator.car.make = self.makesData[indexPath.row];
    [self.coordinator showNextScreenFromScreen:DSScreenCarMake];
}

@end

