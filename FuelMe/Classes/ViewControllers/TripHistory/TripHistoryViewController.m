//
//  TripHistoryViewController.m
//  Ride
//
//  Created by Robert on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSArray+Utils.h"
#import "RAMacros.h"
#import "TripHistoryViewController.h"
#import "TripHistoryAPI.h"
#import "TripHistoryCollectionViewCell.h"
#import "TripHistoryDataModel.h"
#import "TripHistoryDetailTableViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define kLoadingTag 99

@interface TripHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching>

@property (strong, nonatomic) NSMutableArray<TripHistoryDataModel*> *tripHistories;

@property (assign, nonatomic) BOOL firstTimeLoad;
@property (assign, nonatomic) BOOL shouldLoadMoreElements;
@property (strong, nonatomic) NSNumber *currentOffset;
@property (strong, nonatomic) NSNumber *totalPages;
@property (strong, nonatomic) NSNumber *limitTripHistory;
@property (strong, nonatomic) NSMutableArray *indexPathCellAnimated;

@end

@implementation TripHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.cvTripHistory.prefetchDataSource = self;
    }
    
    [self configureData];
    [self loadData];
    [self addReachabilityObserver];
}

- (void)configureData {
    self.tripHistories = [NSMutableArray array];
    self.limitTripHistory = @25;
    self.currentOffset = @0;
    self.firstTimeLoad = YES;
    self.shouldLoadMoreElements = NO;
    self.indexPathCellAnimated = [NSMutableArray array];
}

- (void)loadData {
    if (self.firstTimeLoad) {
        [self showHUD];
    }
    
    __weak TripHistoryViewController *weakSelf = self;
    NSString *riderId = [RASessionManager sharedManager].currentUser.riderID.stringValue;
    [TripHistoryAPI getTripHistoryWithRiderId:riderId limit:self.limitTripHistory offset:self.currentOffset completion:^(NSArray<TripHistoryDataModel *> *tripHistories, NSInteger numberOfElements, NSError *error) {
        [weakSelf hideHUD];
        weakSelf.firstTimeLoad = NO;
        
        weakSelf.shouldLoadMoreElements = !error && [self.currentOffset intValue] < numberOfElements ;
        
        if (!error) {
            if (tripHistories) {
                [weakSelf.tripHistories addObjectsFromArray:tripHistories];
            }
            weakSelf.totalPages = [NSNumber numberWithUnsignedInteger:numberOfElements];
            weakSelf.currentOffset = [NSNumber numberWithInt:weakSelf.currentOffset.intValue + 1];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.cvTripHistory reloadData];
        });
    }];
    
}

- (void)addReachabilityObserver {
    __weak TripHistoryViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self
                                           statusChangedBlock:^(RANetworkReachability networkReachability) {
                                               if (networkReachability == RANetworkReachable) {
                                                   [weakSelf showHUD];
                                                   [weakSelf loadData];
                                               }
                                           }];
}

- (void)dealloc {
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

#pragma mark - Table view datasource and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.shouldLoadMoreElements) {
        return self.tripHistories.count + 1;
    }
    return self.tripHistories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldLoadMoreElements && indexPath.row == self.tripHistories.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TripHistoryLoadingCell" forIndexPath:indexPath];
        UIActivityIndicatorView *aiLoading = [cell.contentView viewWithTag:kLoadingTag];
        [aiLoading startAnimating];
        return cell;
    }
    
    TripHistoryDataModel *tripHistory = [self.tripHistories objectAtIndex:indexPath.row];
    
    TripHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TripHistoryCell" forIndexPath:indexPath];
    
    cell.vContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.lblCost.text = tripHistory.displayTotalCharged;
    cell.lblDate.text = tripHistory.dateString;
    cell.lblStatus.text = tripHistory.statusString;
    cell.lblStatus.hidden = !tripHistory.isCancelled;
    cell.lblCar.text = tripHistory.carInformation;
    [cell.imgTripMap sd_setImageWithURL:tripHistory.mapURL placeholderImage:[UIImage imageNamed:@"map_placeholder"]];
    
    BOOL hasCompletedWithCampaign = tripHistory.isCancelled == NO && tripHistory.hasCampaign;
    [cell.btnCampaignProvider setHidden:!hasCompletedWithCampaign];
    [cell.btnCampaignProvider setTitle:tripHistory.campaignProvider forState:UIControlStateNormal];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat margin = 12.0f;
    
    if (self.shouldLoadMoreElements && indexPath.row == self.tripHistories.count) {
        return CGSizeMake(collectionView.bounds.size.width - margin * 2, 30);
    }
    
    CGSize baseItemSize = CGSizeMake(351, 213);
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat marginInterItem = 6.0;
    CGFloat numberOfElementsToFit = IS_IPAD ? 2 : 1;
    
    CGFloat widthItem = (screenSize.width / numberOfElementsToFit) - (margin * 2) - (numberOfElementsToFit - 1) * marginInterItem;
    CGFloat heightItem = (baseItemSize.height * widthItem) / baseItemSize.width;
    
    return CGSizeMake(widthItem, MAX(baseItemSize.height, heightItem));
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.tripHistories.count) {
        [self loadData];
        return;
    }
    
    if ([self.indexPathCellAnimated containsObject:indexPath]) {
        return;
    }
    
    [self.indexPathCellAnimated addObject:indexPath];
    cell.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        cell.alpha = 1.0;
    }];
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSArray<NSURL*>* mapUrls = [indexPaths mapWithBlock:^NSURL*(NSIndexPath  * _Nonnull indexPath, BOOL * _Nonnull stop) {
        
        if (indexPath.row == self.tripHistories.count) {
            return nil;
        }
        
        return [self.tripHistories objectAtIndex:indexPath.row].mapURL;
    }];

    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:mapUrls];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue_history_detail"]) {
        TripHistoryDetailTableViewController *tripHistoryDetailVC = (TripHistoryDetailTableViewController*)segue.destinationViewController;
        TripHistoryCollectionViewCell *tripCell = (TripHistoryCollectionViewCell*)sender;
        NSIndexPath *indexPathCell = [self.cvTripHistory indexPathForCell:tripCell];
        tripHistoryDetailVC.tripHistory = [self.tripHistories objectAtIndex:indexPathCell.row];
    }
}

@end
