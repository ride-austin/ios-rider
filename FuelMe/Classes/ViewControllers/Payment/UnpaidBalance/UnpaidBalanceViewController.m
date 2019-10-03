//
//  UnpaidBalanceViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UnpaidBalanceViewController.h"

#import <PassKit/PassKit.h>

#import "NSNotificationCenterConstants.h"
#import "PaymentItem.h"
#import "PaymentMethodTableCell.h"
#import "PaymentSectionHeaderCell.h"
#import "RARiderAPI.h"

#import <Stripe/Stripe.h>

@interface UnpaidBalanceViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *applePayToken;

@end

@implementation UnpaidBalanceViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureWithViewModel];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configurations

- (void)configureObserver {
    __weak __typeof__(self) weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidUpdateCurrentRider object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if ([RASessionManager sharedManager].currentRider.unpaidBalance == nil) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:PaymentMethodTableCell.className bundle:nil] forCellReuseIdentifier:PaymentMethodTableCell.className];
    [self.tableView registerNib:[UINib nibWithNibName:PaymentSectionHeaderCell.className bundle:nil] forHeaderFooterViewReuseIdentifier:PaymentSectionHeaderCell.className];
}

- (void)configureWithViewModel {
    self.title = self.viewModel.title;
    self.lbAmount.text = self.viewModel.displayAmount;
}

#pragma mark - IBActions

- (IBAction)didTapSubmit:(UIButton *)sender {
    RARiderDataModel *currentRider = [[RASessionManager sharedManager] currentRider];
    switch (currentRider.preferredPaymentMethod) {
        case PaymentMethodApplePay:
            [self payWithApplePay];
            break;
        case PaymentMethodBevoBucks:
            [self payWithBevoBucks];
            break;
        case PaymentMethodPrimaryCreditCard:
        case PaymentMethodUnspecified:
            [self payWithCreditCard];
            break;
    }
}

#pragma mark - Process Payment

- (void)payWithApplePay {
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.com.rideaustin.public" country:@"US" currency:@"USD"];
    
    PKPaymentSummaryItem *rideCostItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Ride cost" amount:[NSDecimalNumber decimalNumberWithString:self.viewModel.amount]];
    [paymentRequest setPaymentSummaryItems:@[rideCostItem]];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
        PKPaymentAuthorizationViewController *paymentAuthorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        paymentAuthorizationViewController.delegate = self;
        [self presentViewController:paymentAuthorizationViewController animated:YES completion:nil];
    }
}

- (void)payWithBevoBucks {
    if (self.viewModel.bevoBucksUrl && [[UIApplication sharedApplication] canOpenURL:self.viewModel.bevoBucksUrl]) {
        [[UIApplication sharedApplication] openURL:self.viewModel.bevoBucksUrl];
    } else {
        [RAAlertManager showErrorWithAlertItem:@"Sorry, we are unable to proccess BevoBucks Payment" andOptions:[RAAlertOption optionWithState:StateAll]];
    }
}

- (void)payWithCreditCard {
    [self payUnpaidBalanceWithApplePayToken:nil];
}

- (void)payUnpaidBalanceWithApplePayToken:(NSString* __nullable)applePayToken {
    RARiderDataModel *currentRider = [[RASessionManager sharedManager] currentRider];
    NSString *rideId = self.viewModel.rideId;
    
    [self showHUD];
    __weak UnpaidBalanceViewController *weakSelf = self;
    [RARiderAPI payUnpaidBalanceForRiderWithId:currentRider.modelID.stringValue rideId:rideId applePayToken:applePayToken completion:^(NSError *error) {
        if (error) {
            [weakSelf hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
        } else {
            currentRider.unpaidBalance = nil;
            [[RASessionManager sharedManager] saveContext];
            [weakSelf showSuccessHUDandPOP];
        }
    }];
}

#pragma mark - Apple Pay Delegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    __weak UnpaidBalanceViewController *weakSelf = self;
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
        } else {
            weakSelf.applePayToken = token.tokenId;
            completion(PKPaymentAuthorizationStatusSuccess);
        }
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    __weak UnpaidBalanceViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.applePayToken) {
            [weakSelf payUnpaidBalanceWithApplePayToken:weakSelf.applePayToken];
        }
    }];
}

@end

@interface UnpaidBalanceViewController (TableView) <UITableViewDelegate, UITableViewDataSource>
@end

@implementation UnpaidBalanceViewController (TableView)

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PaymentSectionHeaderCell *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:PaymentSectionHeaderCell.className];
    view.lbTitle.text = self.viewModel.headerText;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.selectedPaymentMethod != nil ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentMethodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:PaymentMethodTableCell.className forIndexPath:indexPath];
    cell.paymentItem = self.viewModel.selectedPaymentMethod;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
