//
//  RideCostDetailViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RideCostDetailViewController.h"

#import "CostViewModel.h"
#import "NSObject+className.h"
#import "NSString+Utils.h"
#import "RideCostDetailSeparator.h"
#import "RideCostDetailTableViewCell.h"

#define kHeightRow      15
#define kHeightSection  20

@interface RideCostDetailViewController ()

@property (weak, nonatomic, readonly) RACarCategoryDataModel *selectedCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewToBottom;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbCarCategory;
@property (weak, nonatomic) IBOutlet UILabel *lbProcessingFee;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<NSMutableArray<CostViewModel *>*> *items;

@end

@implementation RideCostDetailViewController

- (instancetype)initWithCarCategory:(RACarCategoryDataModel*)category andSpecialFees:(NSArray*)specialFees {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        _selectedCategory = category;
        [self configureDataWithCategory:category];
        [self configureDataWithSpecialFees:specialFees];
    }
    return self;
}

- (void)configureDataWithCategory:(RACarCategoryDataModel*)category {
    NSMutableArray *section1 = [NSMutableArray new];
    [section1 addObject:[CostViewModel modelWithTitle:[@"BASE FARE" localized] andAmount:category.baseFare.floatValue]];
    [section1 addObject:[CostViewModel modelWithTitle:[@"PER MILE" localized] andAmount:category.ratePerMile.floatValue]];
    [section1 addObject:[CostViewModel modelWithTitle:[@"PER MIN" localized] andAmount:category.ratePerMinute.floatValue]];
    [section1 addObject:[CostViewModel modelWithTitle:[@"MINIMUM FARE" localized] andAmount:category.minimumFare.floatValue]];
    [_items addObject:section1];
    
    NSMutableArray *section2 = [NSMutableArray new];
    [section2 addObject:[CostViewModel modelWithTitle:[@"BOOKING FEE" localized] andAmount:category.bookingFee.floatValue]];
    [section2 addObject:[CostViewModel modelWithTitle:[@"CITY TNC FEE" localized] andRate:category.tncFeeRate]];
    [section2 addObject:[CostViewModel modelWithTitle:[@"PROCESSING FEE" localized] andAmount:category.processingFee.floatValue]];
    [_items addObject:section2];
}

- (void)configureDataWithSpecialFees:(NSArray<RAFee *> *)specialFees {
    NSMutableArray *lastSection = _items.lastObject;
    for (RAFee *fee in specialFees) {
        [lastSection addObject:[CostViewModel modelWithFee:fee]];
    }
}

+ (instancetype)controllerWithCarCategory:(RACarCategoryDataModel*)category andSpecialFees:(NSArray*)specialFees {
    return [[self alloc] initWithCarCategory:category andSpecialFees:specialFees];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureText];
}

- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:[RideCostDetailTableViewCell className] bundle:nil] forCellReuseIdentifier:[RideCostDetailTableViewCell className]];
    [self.tableView registerNib:[UINib nibWithNibName:[RideCostDetailSeparator className] bundle:nil] forHeaderFooterViewReuseIdentifier:[RideCostDetailSeparator className]];
    self.tableView.accessibilityIdentifier = @"pricingDetailsTableView";
}

- (void)configureText {
    self.lbCarCategory.text     = self.selectedCategory.title;
    self.lbProcessingFee.text   = @"";
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateViewHeight];
}

- (void)updateViewHeight {
    CGRect frame = self.view.frame;
    frame.size.height = self.tableView.frame.origin.y + self.tableView.contentSize.height + self.constraintTableViewToBottom.constant;
    [self.view setFrame:frame];
}

@end

@interface RideCostDetailViewController (UITableViewDataSource) <UITableViewDataSource>

@end

@implementation RideCostDetailViewController (UITableViewDataSource)

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RideCostDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RideCostDetailTableViewCell className] forIndexPath:indexPath];
    CostViewModel *vm = self.items[indexPath.section][indexPath.row];
    cell.lbTitle.text = vm.title;
    cell.lbValue.text = vm.displayValue;
    cell.lbDescription.text = vm.feeDescription ?: @"";
    cell.accessibilityValue = [NSString stringWithFormat:@"%f", vm.value];
    cell.accessibilityIdentifier = vm.title;
    return cell;
}

@end

@interface RideCostDetailViewController (UITableViewDelegate) <UITableViewDelegate>

@end

@implementation RideCostDetailViewController (UITableViewDelegate)

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightSection;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return kHeightSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CostViewModel *vm = self.items[indexPath.section][indexPath.row];
    return vm.feeDescription ? 30 : kHeightRow;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHeightRow;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *vSeparator = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[RideCostDetailSeparator className]];
    return vSeparator;
}

@end
