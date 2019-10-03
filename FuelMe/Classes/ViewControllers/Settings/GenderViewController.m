//
//  GenderViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GenderViewController.h"

#import "GenderOptionCell.h"
#import "WomanOnlyViewController.h"

@interface GenderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GenderViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureText];
}

- (void)configureText {
    self.title           = self.viewModel.title;
    self.lbSubtitle.text = self.viewModel.subtitle;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.genders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *gender = self.viewModel.genders[indexPath.row];
    GenderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:GenderOptionCell.className forIndexPath:indexPath];
    cell.textLabel.text = gender;
    if (cell.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Actions

- (IBAction)didTapSave:(UIBarButtonItem *)sender {
    __weak __typeof__(self) weakself = self;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self showHUD];
    [self.viewModel didSelectIndex:indexPath.row withCompletion:^(BOOL success) {
        if (success) {
            [weakself showSuccessHUDWithDismissDelay:1];
        } else {
            [weakself hideHUD];
        }
    }];
}

@end
