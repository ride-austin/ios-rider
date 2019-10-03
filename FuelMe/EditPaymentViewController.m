//
//  EditPaymentViewController.m
//  Ride
//
//  Created by Roberto Abreu on 3/8/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "EditPaymentViewController.h"

#import "RACustomButton.h"
#import "RAPaymentField.h"
#import "RARiderAPI.h"

@interface EditPaymentViewController ()

@property (weak, nonatomic) IBOutlet RAPaymentField *txtCardNumber;
@property (weak, nonatomic) IBOutlet RAPaymentField *txtCardExpiration;
@property (weak, nonatomic) IBOutlet RAPaymentField *txtCardCVV;
@property (weak, nonatomic) IBOutlet RACustomButton *btnSave;

@end

@implementation EditPaymentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}

#pragma mark - Configure UI

- (void)configureUI {
    self.title = @"Edit Payment";
    [self configureFields];
    [self.btnSave setEnabled:NO];
}

- (void)configureFields {
    PaymentItem *paymentItem = [[PaymentItem alloc] initWithCard:self.card];
    self.txtCardNumber.paymentItem = paymentItem;
    self.txtCardExpiration.paymentItem = paymentItem;
    self.txtCardCVV.paymentItem = paymentItem;
    
    [self.txtCardExpiration becomeFirstResponder];
}

#pragma mark - IBActions

- (IBAction)saveTapped:(id)sender {
    if (!self.txtCardExpiration.isValid) {
        return;
    }
    
    NSString *month = self.txtCardExpiration.month;
    NSString *year = [NSString stringWithFormat:@"20%@", self.txtCardExpiration.year];
    NSString *riderId = [RASessionManager sharedManager].currentRider.modelID.stringValue;
    
    [self showHUD];
    __weak EditPaymentViewController *weakSelf = self;
    [RARiderAPI updateCard:self.card forRideWithId:riderId expMonth:month expYear:year withCompletion:^(NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
        } else {
            [weakSelf showSuccessHUDandPOP];
        }
    }];
}

- (IBAction)expirationHasChanged:(id)sender {
    self.btnSave.enabled = self.txtCardExpiration.isValid;
}

- (IBAction)didTapCardNumberOrCVV:(UIButton *)sender {
    [RAAlertManager showAlertWithTitle:@"" message:@"To change card number or CVV, please add a new card"];
}

@end
