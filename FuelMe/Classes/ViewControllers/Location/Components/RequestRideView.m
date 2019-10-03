//
//  RequestRideView.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RequestRideView.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "DNA.h"

@interface RequestRideView()

@property (weak, nonatomic) id <RequestRideViewDelegate> delegate;
@property (weak, nonatomic) id <FemaleDriverModeDataSource> rideRequestManager;
@property (weak, nonatomic) id <RequestRideViewNavigationProtocol> flowController;

@property (weak, nonatomic) IBOutlet UIButton *btFareEstimate;
@property (weak, nonatomic) IBOutlet UIButton *btPromoCode;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIButton *btRequestRide;

@end

@implementation RequestRideView

- (instancetype)initWithFlowController:(id)flowController rideRequestManager:(id<FemaleDriverModeDataSource>)rideRequestManager andDelegate:(id<RequestRideViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.hidden = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.flowController = flowController;
        self.delegate = delegate;
        self.rideRequestManager = rideRequestManager;
        [self configureAccessibility];
        [self updateRequestType:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRequestType:) name:kNotificationDidUpdateFemaleDriverSwitch object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureAccessibility {
    self.btRequestRide.accessibilityLabel  = [@"Request Ride" localized];
    self.btFareEstimate.accessibilityLabel = [@"See Fare Estimate" localized];
    self.btPromoCode.accessibilityLabel    = [@"Enter Promo Code" localized];
    self.btCancel.accessibilityLabel       = [@"Cancel Request" localized];
}

- (IBAction)btFareEstimateTapped:(UIButton *)sender {
    [self.delegate requestRideView:self didTapFareEstimate:sender];
}

- (IBAction)btPromoCodeTapped:(UIButton *)sender {
    [self.flowController navigateToPromotions];
}

- (IBAction)btCancelTapped:(UIButton *)sender {
    [self.delegate requestRideView:self didTapCancel:sender];
}

- (IBAction)btRequestRideTapped:(UIButton *)sender {
    [self.delegate requestRideView:self didTapRequestRide:sender];
}

// MARK: External Methods
- (void)updateButtonCategoryTitle:(NSString *)categoryTitle {
    NSString *title = [NSString stringWithFormat:@"REQUEST %@", categoryTitle];
    [self.btRequestRide setTitle:title forState:UIControlStateNormal];
    self.btRequestRide.accessibilityLabel = title;
}

- (void)updateRequestType:(NSNotification *)notification {
    BOOL isFemaleDriverRequest = [self.rideRequestManager isFemaleDriverModeOn];
    if (notification) {
        isFemaleDriverRequest = [notification.object boolValue];
    }
    UIColor *color = isFemaleDriverRequest ? [UIColor femaleDriverPink] : [UIColor azureBlue];
    [self.btRequestRide setBackgroundColor:color];
}

@end
