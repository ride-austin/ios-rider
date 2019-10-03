//
//  RoundUpViewController.m
//  Ride
//
//  Created by Roberto Abreu on 9/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RoundUpViewController.h"

#import "CharityCollectionViewCell.h"
#import "PersistenceManager.h"
#import "RACharityAPI.h"
#import "RARiderAPI.h"
#import "RASessionManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

static NSString *const kScreenTitle = @"Round up";
static NSString *const kSkipBarButtonItemTitle = @"Skip";
static NSString *const kCharityCellIdentifier = @"kCharityCellIdentifier";

@interface RoundUpViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

//Properties
@property (strong, nonatomic) NSArray<RACharityDataModel*> *charities;

//IBOutlets
@property (weak, nonatomic) IBOutlet UISwitch *switchRoundUp;
@property (weak, nonatomic) IBOutlet UIView *vContainerCharities;
@property (weak, nonatomic) IBOutlet UICollectionView *cvCharities;

@end

@implementation RoundUpViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    [self configureNavigationBar];
    [self configureCollectionViewCharities];
    [self loadCharities];
}

- (void)dealloc {
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

#pragma mark - Configure UI

- (void)configureNavigationBar {
    self.title = kScreenTitle;
    self.navigationController.navigationBar.accessibilityIdentifier = kScreenTitle;
}

- (void)configureCollectionViewCharities {
    [self.cvCharities registerNib:[UINib nibWithNibName:@"CharityCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCharityCellIdentifier];
}

#pragma mark - Observers 

- (void)addObservers {
    __weak RoundUpViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self statusChangedBlock:^(RANetworkReachability networkReachability) {
        if (networkReachability == RANetworkReachable) {
            [weakSelf loadCharities];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)roundUpSwitchChanged:(UISwitch*)sender {
    [self.vContainerCharities setHidden:!sender.isOn];
    if (!sender.isOn) {
        [self updateCurrentRiderWithCharity:nil];
    }
}

#pragma mark - API

- (void)loadCharities {
    [self showHUD];
    __weak RoundUpViewController *weakSelf = self;
    //Reload Current User to get last charity in server
    [[RASessionManager sharedManager] reloadCurrentRiderWithCompletion:^(RARiderDataModel *rider, NSError *error) {
        if (error) {
            [weakSelf hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
        } else {
            
            //Get All charities
            [RACharityAPI getAllCharitiesWithCompletion:^(NSArray<RACharityDataModel *> *charities, NSError *error) {
                [weakSelf hideHUD];
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
                } else {
                    [weakSelf.switchRoundUp setEnabled:YES];
                    weakSelf.charities = charities;
                    [weakSelf.cvCharities reloadData];
                    
                    BOOL userHasCharity = rider.charity != nil;
                    [weakSelf.switchRoundUp setOn:userHasCharity animated:YES];
                    [weakSelf.vContainerCharities setHidden:!userHasCharity];
                }
            }];
            
        }
    }];
}

- (void)updateCurrentRiderWithCharity:(RACharityDataModel*)charity {
    [self showHUD];
    __weak RoundUpViewController *weakSelf = self;
    
    RACharityDataModel *previousCharity = [RASessionManager sharedManager].currentRider.charity;
    [RASessionManager sharedManager].currentRider.charity = charity;
    [self.cvCharities reloadData];
    
    [RARiderAPI updateCurrentRiderCharity:charity withCompletion:^(NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RASessionManager sharedManager].currentRider.charity = previousCharity;
            [weakSelf.switchRoundUp setOn:(previousCharity != nil) animated:YES];
            [self.vContainerCharities setHidden:(previousCharity == nil)];
            [weakSelf.cvCharities reloadData];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
        } else {
            [weakSelf showSuccessHUDandPOP];
        }
    }];
}

#pragma mark - UICollectionView DataSource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.charities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CharityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCharityCellIdentifier forIndexPath:indexPath];
    
    RACharityDataModel *charity = self.charities[indexPath.row];
    RACharityDataModel *currentRiderCharity = [RASessionManager sharedManager].currentRider.charity;
    BOOL isCharitySelectedByUser = currentRiderCharity && [charity.modelID isEqualToNumber:currentRiderCharity.modelID];
    
    [cell.charityImage sd_setImageWithURL:charity.imageURL placeholderImage:nil];
    cell.charityName.text = charity.name;
    cell.checkBox.hidden = !isCharitySelectedByUser;
    cell.charityImage.layer.borderColor = isCharitySelectedByUser ? [UIColor blueColor].CGColor : [UIColor lightGrayColor].CGColor;
    
#ifdef AUTOMATION
    cell.charityName.accessibilityValue = isCharitySelectedByUser ? [NSString stringWithFormat:@"selected %@",charity.name] : @"";
#endif
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RACharityDataModel *charity = self.charities[indexPath.row];
    RACharityDataModel *currentRiderCharity = [RASessionManager sharedManager].currentRider.charity;
    if (charity.modelID == currentRiderCharity.modelID) {
        return;
    }
    
    [self updateCurrentRiderWithCharity:charity];
}

@end
