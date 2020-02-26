//
//  TripHistoryDetailTableViewController.m
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TripHistoryDetailTableViewController.h"

#import "HCSStarRatingView.h"
#import "NSString+Utils.h"
#import "RAMacros.h"
#import "RARideAPI.h"
#import "RatingViewController.h"
#import "RatingViewModel.h"
#import "SupportTopicAPI.h"
#import "UIColor+HexUtils.h"
#import "UIViewController+tripHistoryNavigation.h"
#import "UnratedRide.h"

#import <BFRImageViewer/BFRImageViewer-umbrella.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TripHistoryDetailTableViewController ()

@property (strong, nonatomic) NSArray<SupportTopic*> *supportTopics;

@property (strong, nonatomic) IBOutlet UIView *tripInformationHeaderView;
@property (weak, nonatomic) IBOutlet UIView *vTripInformationContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgTripMap;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UILabel *lblCarName;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDestinationAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgCardBrand;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCard;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgDriverProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblTripMessage;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *vStarRating;
@property (weak, nonatomic) IBOutlet UIButton *btnRateDriver;
@property (weak, nonatomic) IBOutlet UIView *vLineDots;

@property (weak, nonatomic) IBOutlet UIView *campaignContainerView;
@property (weak, nonatomic) IBOutlet UILabel *lblBDRideCost;
@property (weak, nonatomic) IBOutlet UILabel *lblBDRideCostValue;
@property (weak, nonatomic) IBOutlet UILabel *lblBDTip;
@property (weak, nonatomic) IBOutlet UILabel *lblBDTipValue;
@property (weak, nonatomic) IBOutlet UILabel *lblBDCampaignDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblBDCampaignDescriptionValue;
@property (weak, nonatomic) IBOutlet UILabel *lblBDTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblBDTotalValue;
@property (weak, nonatomic) IBOutlet UIButton *btCampaignProvider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCampaignBottomToLastItem;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTipContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRedDotHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCreditCardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDriverPhotoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDriverPhotoBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRatingViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMessageTrailing;

@end

@implementation TripHistoryDetailTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.supportTopics = @[];
    [self loadSupportTopics];
    
    [self setupUI];
    [self addReachabilityObserver];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.tableView.tableHeaderView) {
        self.tripInformationHeaderView.frame = CGRectMake(0,0,self.tableView.bounds.size.width,CGFLOAT_MAX);
        CGRect headerFrame = [self.tripInformationHeaderView bounds];
        [self.tripInformationHeaderView setNeedsLayout];
        [self.tripInformationHeaderView layoutIfNeeded];
        CGFloat finalHeight = [self.tripInformationHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        headerFrame.size.height = finalHeight;
        self.tripInformationHeaderView.frame = headerFrame;
        self.tableView.tableHeaderView = self.tripInformationHeaderView;
    }
}

- (void)dealloc {
    [[RANetworkManager sharedManager] removeReachabilityObserver:self];
}

#pragma mark - Configure UI

- (void)setupUI {
    
    TripHistoryDataModel *model = self.tripHistory;
    
    self.vTripInformationContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.lblDate.text = self.tripHistory.dateString;
    self.lblCost.text = self.tripHistory.displayTotalCharged;
    self.lblPickupAddress.text = self.tripHistory.startAddress;
    self.lblDestinationAddress.text = self.tripHistory.endAddress;
    self.lblCarName.text = self.tripHistory.carInformation;
    [self.imgTripMap sd_setImageWithURL:self.tripHistory.mapURL placeholderImage:[UIImage imageNamed:@"map_placeholder"]];
    
    //Configure UI - Based on missing Data
    if (IS_EMPTY(self.tripHistory.endAddress)) {
        self.constraintRedDotHeight.constant = 0;
        self.lblDestinationAddress.hidden = YES;
        self.vLineDots.hidden = YES;
    }
    
    if (self.tripHistory.hasCreditCardInfo) {
        self.imgCardBrand.image = [UIImage imageNamed:self.tripHistory.cardBrand.lowercaseString];
        self.imgCardBrand.contentMode = UIViewContentModeScaleToFill;
        self.lblCreditCard.text = [NSString stringWithFormat:@"**** **** **** %@",self.tripHistory.cardNumber];
    } else if (self.tripHistory.otherPaymentMethodUrl) {
        [self.imgCardBrand sd_setImageWithURL:self.tripHistory.otherPaymentMethodUrl];
        self.imgCardBrand.contentMode = UIViewContentModeScaleAspectFit;
        self.lblCreditCard.hidden = YES;
    } else {
        self.constraintCreditCardHeight.constant = 0;
        self.lblCreditCard.hidden = YES;
    }
    
    if (self.tripHistory.isCancelled) {
        self.constraintRatingViewWidth.constant = 0;
        self.constraintDriverPhotoHeight.constant = 0;
        self.constraintMessageTrailing.constant = 0;
        self.constraintDriverPhotoBottom.constant = 10;
        self.lblTripMessage.hidden = YES;
        self.lblStatus.hidden = NO;
        self.lblStatus.text = self.tripHistory.statusString;
    } else {
        
        self.vStarRating.hidden = YES;
        self.btnRateDriver.hidden = YES;
        
        if (self.tripHistory.driverRating) {
            self.lblTripMessage.text = [NSString stringWithFormat:[@"You rated %@" localized],self.tripHistory.displayName];
            self.vStarRating.value = [self.tripHistory.driverRating intValue];
            self.vStarRating.hidden = NO;
        } else if (self.tripHistory.isMainRider) {
            self.btnRateDriver.hidden = NO;
            self.lblTripMessage.text = [NSString stringWithFormat:[@"Your driver is %@" localized], self.tripHistory.displayName];
        } else {
            self.constraintRatingViewWidth.constant = 0;
            self.lblTripMessage.text = [NSString stringWithFormat:[@"Your driver is %@" localized], self.tripHistory.displayName];
        }
        
        if (self.tripHistory.driverPictureURL) {
            [self.imgDriverProfile sd_setImageWithURL:self.tripHistory.driverPictureURL];
        }
        
        
    }
    
    //
    //  Campaign
    //
    BOOL hasCompletedWithCampaign = model.hasCampaign && model.isCancelled == NO;
    self.constraintCampaignBottomToLastItem.active = hasCompletedWithCampaign;
    self.btCampaignProvider.hidden = hasCompletedWithCampaign == NO;
    if (hasCompletedWithCampaign) {
        [self.btCampaignProvider setTitle:model.campaignProvider forState:UIControlStateNormal];
        self.lblBDRideCost.text = @"Ride Cost";
        if (model.hasTip) {
            self.lblBDTip.text = @"Tip";
            self.lblBDTipValue.text = model.displayTip;
        } else {
            self.constraintTipContainerHeight.constant = 0.0;
        }
        self.lblBDTotal.text = @"Total";
        self.lblBDRideCostValue.text = model.displayRideCost;
        self.lblBDCampaignDescription.text = model.campaignDescriptionHistory;
        self.lblBDCampaignDescriptionValue.text = model.displayDiscount;
        self.lblBDTotalValue.text = model.displayTotalCharged;
        self.lblBDTotalValue.font = self.lblBDCampaignDescriptionValue.font;
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
}

#pragma mark - Observers

- (void)addReachabilityObserver{
    __weak TripHistoryDetailTableViewController *weakSelf = self;
    [[RANetworkManager sharedManager] addReachabilityObserver:self
                                           statusChangedBlock:^(RANetworkReachability networkReachability) {
                                               if (networkReachability == RANetworkReachable) {
                                                   [weakSelf setupUI];
                                                   [weakSelf loadSupportTopics];
                                               }
                                           }];
}

#pragma mark - IBActions

- (IBAction)showMapFullScreen:(id)sender {
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[self.imgTripMap.image]];
    imageVC.enableDoneButton = NO;
    [self.navigationController presentViewController:imageVC animated:YES completion:nil];
}

- (IBAction)rateDriverTapped:(id)sender {
    __weak TripHistoryDetailTableViewController *weakSelf = self;
    [RARideAPI getRide:[self.tripHistory.rideId stringValue] withRiderLocation:nil andCompletion:^(RARideDataModel *ride, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
        } else {
            RatingViewController *ratingViewController = [[RatingViewController alloc] init];
            ratingViewController.viewModel = [[RatingViewModel alloc] initWithRide:[[UnratedRide alloc] initWithRide:ride andPaymentMethod:PaymentMethodUnspecified] configuration:[ConfigurationManager shared]];
            ratingViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            ratingViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            ratingViewController.ratingSelectedBlock = ^(CGFloat rating) {
                weakSelf.tripHistory.driverRating = [NSNumber numberWithFloat:rating];
                [weakSelf setupUI];
            };
            [weakSelf presentViewController:ratingViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark - Load support topics

- (void)loadSupportTopics {
    [SVProgressHUD show];
    [SupportTopicAPI getSupportTopicListWithCompletion:^(NSArray<SupportTopic *> *supportTopics, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            self.supportTopics = supportTopics;
            [self.tableView reloadData];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.supportTopics.count == 0) ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.supportTopics.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width,50)];
    bgView.backgroundColor = [UIColor colorWithHex:@"F2F4F4"];
    UILabel *lblHelp = [[UILabel alloc] initWithFrame:CGRectInset(bgView.bounds, 16.0, 0)];
    lblHelp.textColor = [UIColor colorWithRed:44/255.0 green:50/255.0 blue:60/255.0 alpha:1.0];
    lblHelp.text = [@"Help" localized];
    lblHelp.font = [UIFont fontWithName:FontTypeLight size:13.0];
    [bgView addSubview:lblHelp];
    return bgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelpTripCell" forIndexPath:indexPath];
    
    SupportTopic *supportTopic = self.supportTopics[indexPath.row];
    cell.textLabel.text = supportTopic.topicDescription;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SupportTopic *supportTopic = self.supportTopics[indexPath.row];
    [self showNextScreenForTopic:supportTopic withTripHistory:self.tripHistory];
}

@end
