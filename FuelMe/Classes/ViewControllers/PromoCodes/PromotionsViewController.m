//
//  PromotionsViewController.m
//  Ride
//
//  Created by Kitos on 6/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PromotionsViewController.h"

#import "CreditDetailViewController.h"
#import "FreeRidesViewController.h"
#import "LocationService.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "PromotionsViewModel.h"
#import "RACustomButton.h"
#import "RACustomTextField.h"
#import "RAPromoCode.h"
#import "RAPromoCodeAPI.h"
#import "RARiderAPI.h"
#import "UIColor+HexUtils.h"
#import <KVOController/NSObject+FBKVOController.h>

@interface PromotionsViewController () <RACustomTextFieldDelegate, UITextFieldDelegate>

//Properties
@property (strong, nonatomic) PromotionsViewModel *promotionsViewModel;
@property (strong, nonatomic) UITapGestureRecognizer *creditTapGestureRecognizer;

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *lblPromoCodeTitle;
@property (weak, nonatomic) IBOutlet RACustomTextField *promoCodeTextfield;
@property (weak, nonatomic) IBOutlet RACustomButton *applyBtn;
@property (weak, nonatomic) IBOutlet UIView *inviteFriendsView;
@property (weak, nonatomic) IBOutlet UIView *creditBalanceContainer;
@property (weak, nonatomic) IBOutlet UIImageView *iconCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditAvailable;
@property (weak, nonatomic) IBOutlet UIImageView *imgCreditDetailChevron;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiCreditLoading;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteFriendsContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creditBalanceContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creditBalanceContainerHeightConstraint;

//IBActions
- (IBAction)applyPromoCode:(UIButton*)sender;
- (IBAction)backgroundTouched:(UITapGestureRecognizer*)sender;
- (IBAction)inviteFriendsTouched:(UIButton *)sender;

- (void)applyPromoCodeLiteral:(NSString*)promoCodeLiteral;

@end

@implementation PromotionsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Attach Observers
    [self addNotificationObservers];
    [self addKVOObservers];
    
    //Reload config
    [self reloadConfiguration];
    
    //Setup ViewModel
    ConfigGlobal *configGlobal = [ConfigurationManager shared].global;
    self.promotionsViewModel = [[PromotionsViewModel alloc] initWithConfiguration:configGlobal];
    self.creditTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(creditTouched:)];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.promotionsViewModel loadRemainingCredit];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)setupUI {
    
    self.title = self.promotionsViewModel.title;
    
    //Setup Promocode
    self.lblPromoCodeTitle.text = self.promotionsViewModel.promoCodeTitle;
    
    //Setup ReferFriend
    self.inviteFriendsContainerHeightConstraint.constant = self.promotionsViewModel.referFriendHeightContainer;
    
    //Setup CreditBalance
    self.creditBalanceContainerTopConstraint.constant = self.promotionsViewModel.creditBalanceTopOffset;
    self.creditBalanceContainerHeightConstraint.constant = self.promotionsViewModel.creditBalanceHeightContainer;
    self.iconCredit.image = [UIImage imageNamed:self.promotionsViewModel.creditIconName];
    self.lblCreditTitle.text = self.promotionsViewModel.creditTitle;
    self.lblCreditAvailable.text = self.promotionsViewModel.creditTotal;
    self.imgCreditDetailChevron.hidden = !self.promotionsViewModel.isCreditBalanceDetailAvailable;
    
    if (self.promotionsViewModel.isActivityIndicatorCreditBalanceLoading) {
        [self.aiCreditLoading startAnimating];
    } else {
        [self.aiCreditLoading stopAnimating];
    }
    
    [self.creditBalanceContainer removeGestureRecognizer:self.creditTapGestureRecognizer];
    if (self.promotionsViewModel.isCreditBalanceDetailAvailable) {
        [self.creditBalanceContainer addGestureRecognizer:self.creditTapGestureRecognizer];
    }
    
    [self.view layoutIfNeeded];
}

- (void)reloadConfiguration {
    [ConfigurationManager needsReload];
    [ConfigurationManager checkConfigurationBasedOnLocation:[LocationService sharedService].myLocation];
}

- (void)setApplyBtnEnable:(BOOL)enabled {
    self.applyBtn.enabled = enabled;
    self.applyBtn.backgroundColor = enabled ? [UIColor colorWithHex:@"#02A7F9"] : [UIColor colorWithHex:@"#D8D8D8"];
}

#pragma mark - IBActions

- (IBAction)applyPromoCode:(UIButton *)sender{
    [self applyPromoCodeLiteral:self.promoCodeTextfield.text];
}

- (IBAction)backgroundTouched:(UITapGestureRecognizer*)sender{
    [self dismissKeyboard];
}

- (IBAction)inviteFriendsTouched:(UIButton *)sender {
    FreeRidesViewController *frvc = [FreeRidesViewController new];
    [self.navigationController pushViewController:frvc animated:YES];
}

- (IBAction)creditTouched:(id)sender {
    UIViewController *creditDetailViewController = [[UIStoryboard storyboardWithName:@"CreditDetail" bundle:nil] instantiateViewControllerWithIdentifier:CreditDetailViewController.className];
    [self.navigationController pushViewController:creditDetailViewController animated:YES];
}

#pragma mark - Observers

- (void)addNotificationObservers {
    __weak PromotionsViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidChangeConfiguration object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.promotionsViewModel setConfigGlobal:[ConfigurationManager shared].global];
        [UIView animateWithDuration:0.5 animations:^{
            [weakSelf setupUI];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidUpdateCurrentRider object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.KVOController unobserveAll];
        [weakSelf addKVOObservers];
        [weakSelf.promotionsViewModel loadRemainingCredit];
    }];
}

- (void)addKVOObservers {
    __weak PromotionsViewController *weakSelf = self;
    
    RARiderDataModel *currentRider = [RASessionManager sharedManager].currentRider;
    [self.KVOController observe:currentRider keyPath:@"remainingCredit" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf setupUI];
    }];
}

#pragma mark - CustomTextField Delegate

- (void)textField:(RACustomTextField *)textfield hasChangedBorderEnabled:(BOOL)enabled{
    [self setApplyBtnEnable:enabled];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self applyPromoCodeLiteral:textField.text];
    return YES;
}

#pragma mark - PromoCode Redemption

- (void)applyPromoCodeLiteral:(NSString *)promoCodeLiteral {
    [self dismissKeyboard];
    [self showHUD];
    
    __weak PromotionsViewController *weakSelf = self;
    [RAPromoCodeAPI applyPromoCode:promoCodeLiteral completion:^(RAPromoCode *promoCode, NSError *error) {
        [weakSelf hideHUD];
        weakSelf.promoCodeTextfield.text = @"";
        [weakSelf.promoCodeTextfield setBorderEnabled:NO];
        
        NSString *message;
        if (!error) {
            [RASessionManager sharedManager].currentRider.remainingCredit = promoCode.remainingCredit;
            message = [NSString stringWithFormat:[@"Congratulations!\nThe promo code \"%@\" has been applied.\n$%.2f has been added to your account." localized], promoCode.codeLiteral, [promoCode.codeValue doubleValue]];
        } else {
            message = error.localizedRecoverySuggestion ? error.localizedRecoverySuggestion : error.localizedDescription;
        }
        
        [RAAlertManager showAlertWithTitle:[@"Promo Code" localized] message:message options:[RAAlertOption optionWithState:StateActive]];
    }];
}

@end
