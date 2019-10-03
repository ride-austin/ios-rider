//
//  CategoryChooserViewController.m
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CategoryChooserViewController.h"
#import "CarCategoriesManager.h"
#import "DCCarCategoryTableViewCell.h"
#import "DNA.h"
#import "NSString+Utils.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface CategoryChooserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CategoryChooserViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDesign];
}

#pragma mark - Configure UI

- (void)setupDesign {
    self.tableView.backgroundColor = self.view.backgroundColor;
}

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
    }
    return formatter;
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.carCategories.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lblHeader = [[UILabel alloc] init];
    lblHeader.text = [@"Car Categories" localized];
    lblHeader.font = [UIFont fontWithName:FontTypeLight size:14.0];
    [lblHeader sizeToFit];
    return lblHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCCarCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    NSString *categoryName = self.carCategories[indexPath.row];
    RACarCategoryDataModel *categoryDataModel = [CarCategoriesManager getCategoryByName:categoryName];
    
    cell.lblName.text = categoryDataModel.title;
    [cell.imgCategory sd_setImageWithURL:categoryDataModel.plainIconUrl placeholderImage:nil];
    
    NSNumber *categoryFactor = self.factors[categoryName];
    BOOL shouldShowPriorityFare = categoryFactor.floatValue > 1.0;
    cell.lblPriorityMultiplier.text = [[self numberFormatter] stringFromNumber:categoryFactor];
    cell.lblPriorityMultiplier.hidden = !shouldShowPriorityFare;
    cell.imgPriority.hidden = !shouldShowPriorityFare;
    cell.lblCategoryDescription.text = [NSString stringWithFormat:[@"%d Seats" localized], categoryDataModel.maxPersons.intValue];
    
    if ([categoryDataModel isEqual:self.categorySelected]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.layer.mask = nil;
    cell.layer.masksToBounds = YES;
    
    //Set round corner to first and last row
    NSInteger lastCellIndex = self.carCategories.count - 1;
    if (indexPath.row == 0 || indexPath.row == lastCellIndex) {
        UIRectCorner roundingCorner = indexPath.row == 0 ? (UIRectCornerTopLeft | UIRectCornerTopRight) : (UIRectCornerBottomLeft | UIRectCornerBottomRight);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:cell.bounds byRoundingCorners:roundingCorner cornerRadii:CGSizeMake(6.0, 6.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        cell.layer.mask = maskLayer;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *categoryName = self.carCategories[indexPath.row];
    RACarCategoryDataModel *categoryDataModel = [CarCategoriesManager getCategoryByName:categoryName];
    self.categorySelected = categoryDataModel;
    
    if (self.delegate) {
        [self.delegate didChooseCategoryWithName:categoryName];
    }
    
    [tableView reloadData];
}

@end
