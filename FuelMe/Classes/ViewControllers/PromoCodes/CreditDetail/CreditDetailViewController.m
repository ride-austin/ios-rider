//
//  CreditDetailViewController.m
//  Ride
//
//  Created by Roberto Abreu on 8/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CreditDetailViewController.h"
#import "CreditHeaderCollectionReusableView.h"
#import "CreditDetailCollectionViewCell.h"
#import "ConfigurationManager.h"
#import "RAMacros.h"
#import "RARiderAPI.h"
#import "RedemptionViewModel.h"
#import "RASessionManager.h"
#import <KVOController/NSObject+FBKVOController.h>
#import "RAAlertManager.h"
#import "NSArray+Utils.h"

static NSString *const kHeaderIdentifier = @"creditsAvailableHeader";
static NSString *const kCellIdentifier = @"creditDetailCell";

@interface CreditDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *redemptions;

@end

@implementation CreditDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addKVOObservers];
    [self addReachabilityObserver];
    [self loadRedemptionsData];
}

#pragma mark - Observers

- (void)addReachabilityObserver {
    __weak CreditDetailViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self
                                           statusChangedBlock:^(RANetworkReachability networkReachability) {
                                               if (networkReachability == RANetworkReachable) {
                                                   [weakSelf.aiLoading startAnimating];
                                                   [weakSelf loadRedemptionsData];
                                               }
                                           }];
}

- (void)addKVOObservers {
    __weak CreditDetailViewController *weakSelf = self;
    
    RARiderDataModel *currentRider = [RASessionManager sharedManager].currentRider;
    [self.KVOController observe:currentRider keyPath:@"remainingCredit" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - Loading Data

- (void)loadRedemptionsData {
    NSString *riderId = [[RASessionManager sharedManager] currentRider].modelID.stringValue;
    __weak CreditDetailViewController *weakSelf = self;
    [RARiderAPI redemptionsForRiderWithId:riderId completion:^(NSArray<RARedemption *> *redemptions, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            weakSelf.redemptions = [redemptions mapWithBlock:^id _Nullable(RARedemption *_Nonnull redemption, BOOL * _Nonnull stop) {
                return [[RedemptionViewModel alloc] initWithRedemption:redemption];
            }];
        }
        
        [weakSelf.aiLoading stopAnimating];
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.redemptions.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CreditHeaderCollectionReusableView *creditHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
        
        creditHeader.lblTitleHeader.text = [ConfigurationManager shared].global.promoCredits.detailTitle;
        
        NSNumber *remainingCredit = [RASessionManager sharedManager].currentRider.remainingCredit;
        if (remainingCredit) {
            creditHeader.lblTotalCredit.text = [[NSString stringWithFormat:@"$%.2f", remainingCredit.doubleValue] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        } else {
            creditHeader.lblTotalCredit.text = @"";
        }
        
        return creditHeader;
    }
    
    return [UICollectionReusableView new];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CreditDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    RedemptionViewModel *redemptionViewModel = self.redemptions[indexPath.row];
    [cell configureWithViewModel:redemptionViewModel];
    
    return cell;
}

#pragma mark - UICollectionView DelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    const CGFloat sideTotalMargin = 40;
    const CGFloat cellHeight = 99;
    CGFloat collectionViewWidth = collectionView.bounds.size.width;
    
    if (IS_IPAD) {
        return CGSizeMake((collectionViewWidth - sideTotalMargin * 2) / 2, cellHeight);
    } else {
        return CGSizeMake(collectionViewWidth - sideTotalMargin, cellHeight);
    }
}

@end
