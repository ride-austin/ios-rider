//
//  ColorViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "ColorViewController.h"

#import "Ride-Swift.h"

@interface ColorViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet NSArray<NSString *> *data;

@end

@implementation ColorViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[@"Black",@"Blue",@"Brown",@"Gray",@"Green",@"Orange",@"Red",@"Silver",@"White",@"Yellow/Gold"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (DSCar *)car {
    return self.coordinator.car;
}

#pragma mark - UITableView Datasource & Delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@ %@", self.car.year, self.car.make, self.car.model];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"ColorViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.car.color = self.data[indexPath.row];
    [self.coordinator showNextScreenFromScreen:DSScreenCarColor];
}

@end
