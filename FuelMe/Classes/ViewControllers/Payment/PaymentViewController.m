//
//  PaymentViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 8/27/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "PaymentViewController.h"

#import "AddPaymentViewController.h"
#import "ApplePayHelper.h"
#import "EditPaymentViewController.h"
#import "NSNotificationCenterConstants.h"
#import "NSObject+className.h"
#import "PaymentItem.h"
#import "PaymentMethodTableCell.h"
#import "PaymentSectionFooterCell.h"
#import "PaymentSectionHeaderCell.h"
#import "PaymentSectionItem.h"
#import "RAMacros.h"
#import "RAPaymentProviderInformationPopup.h"
#import "RARideManager.h"
#import "RARiderDataModel.h"
#import "UnpaidBalanceViewController.h"

#import <Stripe/Stripe.h>

static NSString *const kScreenTitle = @"Payment";

#define kTextColorUnpaidBalance [UIColor colorWithRed:250.0/255 green:7.0/255 blue:7.0/255 alpha:1.0]

@interface PaymentViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<PaymentItem*> *paymentMethods;
@property (nonatomic) NSMutableArray<PaymentSectionItem *> *sections;
@property (nonatomic) PaymentItem *applePayPaymentItem;
@end

@implementation PaymentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self showCardExpirationAlertIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureSections];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self hideHUD];
}

#pragma mark - Configure UI

- (void)configureUI {
    self.title = kScreenTitle;
    self.navigationController.navigationBar.accessibilityIdentifier = kScreenTitle;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureTableView];
}

- (void)configureTableView {
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:PaymentMethodTableCell.className bundle:nil] forCellReuseIdentifier:PaymentMethodTableCell.className];
    [self.tableView registerNib:[UINib nibWithNibName:PaymentSectionHeaderCell.className bundle:nil] forHeaderFooterViewReuseIdentifier:PaymentSectionHeaderCell.className];
    [self.tableView registerNib:[UINib nibWithNibName:PaymentSectionFooterCell.className bundle:nil] forHeaderFooterViewReuseIdentifier:PaymentSectionFooterCell.className];
    self.tableView.tableFooterView = self.tableFooterView;
}

#pragma mark - Configure DataSource

- (void)configureSections {
    [self showHUD];
    __weak PaymentViewController *weakSelf = self;
    [[RASessionManager sharedManager] reloadCurrentRiderWithCompletion:^(RARiderDataModel *rider, NSError *error) {
        [weakSelf hideHUD];
        weakSelf.sections = [NSMutableArray new];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
        }
        
        //Unpaid balance section
        RAUnpaidBalance *unpaidBalance = rider.unpaidBalance;
        ConfigUnpaidBalance *config = [ConfigurationManager shared].global.unpaidBalance;
        if (unpaidBalance && config.enabled) {
            PaymentItem *pay = [PaymentItem paymentItemWithText:unpaidBalance.displayAmount
                                                      textColor:kTextColorUnpaidBalance
                                                    andIconItem:[UIImage imageNamed:@"icon-unpaid-balance"]
                                                  accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            pay.didSelectItem = ^(PaymentItem *paymentItem) {
                [weakSelf showUnpaidBalance:unpaidBalance];
            };
            PaymentSectionItem *sectionUnpaidBalance = [PaymentSectionItem itemWithHeader:config.title footer:config.subtitle andRowItems:@[pay]];
            [weakSelf.sections addObject:sectionUnpaidBalance];
        }
        
        //Payment Method Section
        weakSelf.paymentMethods = [weakSelf configurePaymentMethods];
        PaymentSectionItem *sectionPaymentMethods = [PaymentSectionItem itemWithHeader:@"Payment methods" footer:@"" andRowItems:weakSelf.paymentMethods];
        [weakSelf.sections addObject:sectionPaymentMethods];
        [weakSelf configurePaymentMethods];
        [weakSelf.tableView reloadData];
    }];
}

- (NSArray<PaymentItem*>*)configurePaymentMethods {
    __weak __typeof__(self) weakself = self;
    
    NSMutableArray<PaymentItem*> *paymentItems = [NSMutableArray new];
    
    //Configure Apple Pay
    if ([ApplePayHelper canMakePayment]) {
        NSString *text = [ApplePayHelper hasApplePaySetup] ? kTitleApplePay : kTitleSetupApplePay;
        UIColor *textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
        
        if (!self.applePayPaymentItem) {
            PaymentItem *item = [PaymentItem paymentItemWithText:text textColor:textColor andIconItem:[UIImage imageNamed:@"apple_pay"]];
            item.didSelectItem = ^(PaymentItem *paymentItem) {
                
                if (weakself.canChangePaymentMethod) {
                    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
                    if (rider.preferredPaymentMethod == PaymentMethodApplePay) {
                        rider.preferredPaymentMethod =  PaymentMethodPrimaryCreditCard;
                        [weakself.tableView reloadData];
                    } else {
                        if ([ApplePayHelper hasApplePaySetup]) {
                            rider.preferredPaymentMethod = PaymentMethodApplePay;
                            if ([paymentItem.text isEqualToString:@"Setup Apple Pay"]) {
                                [weakself updateApplePayButton];
                            } else {
                                [weakself.tableView reloadData];
                            }
                        } else {
                            [ApplePayHelper openSettingsApplePay];
                        }
                    }
                } else {
                    [weakself showCantChangePaymentMethodAlert];
                }
            };
            self.applePayPaymentItem = item;
        }
        [self.applePayPaymentItem updateText:text];
        [paymentItems addObject:self.applePayPaymentItem];
    }
    
    //Configure BevoBucks
    ConfigUTPayWithBevoBucks *payWithBevoBucks = [ConfigurationManager shared].global.ut.payWithBevoBucks;
    if (payWithBevoBucks.enabled) {
        UIColor *textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
        PaymentItem *bevoPay = [PaymentItem paymentItemWithText:@"Bevo Pay" textColor:textColor andIconItem:[UIImage imageNamed:@"bevoPay"]];
        bevoPay.didSelectItem = ^(PaymentItem *paymentItem) {
            if (weakself.canChangePaymentMethod) {
                RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
                rider.preferredPaymentMethod = (rider.preferredPaymentMethod == PaymentMethodBevoBucks) ? PaymentMethodPrimaryCreditCard : PaymentMethodBevoBucks;
                [weakself.tableView reloadData];
            } else {
                [weakself showCantChangePaymentMethodAlert];
            }
        };
        __block RAPaymentProviderInformationPopup *popup; //keep strong reference outside the block
        bevoPay.didTapInfoButton = ^{
            popup = [RAPaymentProviderInformationPopup paymentProviderWithPhotoURL:payWithBevoBucks.iconLargeUrl name:@"Bevo Pay" detail:payWithBevoBucks.shortDescription];
            [popup show];
        };
        [paymentItems addObject:bevoPay];
    }
    
    //Configure Credit Cards
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    NSMutableArray *creditCardPaymentItems = [NSMutableArray array];
    for (RACardDataModel *card in rider.cards) {
        if (!IS_NULL(card) && !IS_NULL(card.cardNumber)) {
            PaymentItem *creditCardPaymentItem = [PaymentItem paymentItemWithCard:card];
            creditCardPaymentItem.didSelectItem = ^(PaymentItem *paymentItem) {
                if (weakself.canChangePaymentMethod) {
                    [weakself didSelectPaymentItemWithCard:paymentItem];
                } else {
                    [weakself showCantChangePaymentMethodAlert];
                }
            };
            [creditCardPaymentItems addObject:creditCardPaymentItem];
        }
    }
    [paymentItems addObjectsFromArray:creditCardPaymentItems];
    
    //Configure extra options
    UIColor *textColor = [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    PaymentItem *addPayment = [PaymentItem paymentItemWithText:@"Add Payment" textColor:textColor andIconItem:[UIImage imageNamed:@"add-icon"]];
    addPayment.didSelectItem = ^(PaymentItem *paymentItem) {
        AddPaymentViewController *aVC = [[AddPaymentViewController alloc] init];
        [weakself.navigationController pushViewController:aVC animated:YES];
    };
    [paymentItems addObject:addPayment];
    
    return paymentItems;
}

#pragma mark - Observers

- (void)addObservers {
    if ([ApplePayHelper canMakePayment]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateApplePayButton)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configureSections)
                                                 name:kNotificationDidChangeConfiguration
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateApplePayButton {
    if (self.applePayPaymentItem) {
        NSString *text = [ApplePayHelper hasApplePaySetup] ? kTitleApplePay : kTitleSetupApplePay;
        BOOL didChangeText = [self.applePayPaymentItem.text isEqualToString:text] == NO;
        [self.applePayPaymentItem updateText:text];
        
        RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
        BOOL isApplePaySelectedAndNoAvailableCards = rider.preferredPaymentMethod == PaymentMethodApplePay && [ApplePayHelper hasApplePaySetup] == NO;
        if (isApplePaySelectedAndNoAvailableCards) {
            rider.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
            [self.tableView reloadData]; //reload primary card and apple pay payment item
        } else if (didChangeText) {
            [self.tableView reloadData]; //reload primary card and apple pay payment item
        }
    }
}

#pragma mark - UITableView datasource / delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PaymentSectionItem *sectionItem = self.sections[section];
    PaymentSectionHeaderCell *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:PaymentSectionHeaderCell.className];
    view.lbTitle.text = sectionItem.header;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 48;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    PaymentSectionItem *sectionItem = self.sections[section];
    
    PaymentSectionFooterCell *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:PaymentSectionFooterCell.className];
    view.lbTitle.text = sectionItem.footer;
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].rowItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    PaymentSectionItem *section = self.sections[indexPath.section];
    PaymentItem *paymentItem = section.rowItems[indexPath.row];
    
    PaymentMethodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:PaymentMethodTableCell.className forIndexPath:indexPath];
    cell.paymentItem = paymentItem;
    
    if (paymentItem.isCreditCard) {
        if ([paymentItem.card.primary boolValue] &&
            (rider.preferredPaymentMethod == PaymentMethodPrimaryCreditCard ||
             rider.preferredPaymentMethod == PaymentMethodUnspecified)) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessibilityLabel = [NSString stringWithFormat:@"Primary Card ending in %@",paymentItem.card.cardNumber];
            cell.accessibilityHint = nil;
        }
    } else {
        cell.accessibilityLabel = paymentItem.text;
        cell.contentView.alpha = 1.0;
    }
    
    if (paymentItem.isApplePay && rider.preferredPaymentMethod == PaymentMethodApplePay) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (paymentItem.isBevoBucks && rider.preferredPaymentMethod == PaymentMethodBevoBucks) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PaymentItem *paymentItem = self.sections[indexPath.section].rowItems[indexPath.row];
    if (paymentItem.didSelectItem) {
        paymentItem.didSelectItem(paymentItem);
    }
}

- (void)didSelectPaymentItemWithCard:(PaymentItem*)paymentItem {
    
    NSInteger row = [self.paymentMethods indexOfObject:paymentItem];
    NSInteger section = self.sections.count - 1;
    NSIndexPath *indexPathForPaymentItem = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPathForPaymentItem];
    
    __block RACardDataModel *card = paymentItem.card;
    __weak PaymentViewController *weakSelf = self;
    
    if(![card.primary boolValue]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Card Options" message:@"Please, choose an option:" preferredStyle:UIAlertControllerStyleActionSheet];
        alertController.popoverPresentationController.sourceView = cell;
        alertController.popoverPresentationController.sourceRect = cell.bounds;
        
        if (![card.cardExpired boolValue]) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Set as primary card" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf processPrimaryCard:card];
            }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Edit Card" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showEditPaymentForCard:card];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete Card" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showDeleteConfirmationForCard:card];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:true completion:nil];
    }else{
        RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
        
        if (rider.preferredPaymentMethod == PaymentMethodApplePay) {
            rider.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
            [self.tableView reloadData];
        } else if (rider.preferredPaymentMethod == PaymentMethodBevoBucks) {
            rider.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
            [self.tableView reloadData];
        } else {
            [self showEditPaymentForCard:card];
        }
    }
}

- (void)processPrimaryCard:(RACardDataModel*)card {
    [self showHUD];
    __weak PaymentViewController *weakSelf = self;

    RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
    [rider setPrimaryCard:card withCompletion:^(NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
            return;
        }
        [weakSelf configureSections];
    }];
}

- (void)showEditPaymentForCard:(RACardDataModel *)card {
    EditPaymentViewController *editPaymentViewController = [[EditPaymentViewController alloc] init];
    editPaymentViewController.card = card;
    [self.navigationController pushViewController:editPaymentViewController animated:YES];
}

- (void)showDeleteConfirmationForCard:(RACardDataModel*)card {
    __weak PaymentViewController *weakSelf = self;
    UIAlertController *deleteConfirmation = [UIAlertController alertControllerWithTitle:@"Delete Confirmation" message:@"Are you sure you want to delete this credit card?" preferredStyle:UIAlertControllerStyleAlert];
    
    [deleteConfirmation addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [deleteConfirmation addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteCard:card];
    }]];
    
    [weakSelf presentViewController:deleteConfirmation animated:YES completion:nil];
}

- (void)deleteCard:(RACardDataModel*)card {
    [self showHUD];
    __weak PaymentViewController *weakSelf = self;

    RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
    [rider deleteCard:card withCompletion:^(NSError *error) {
        if(error){
            [weakSelf hideHUD];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
            return;
        }
        
        [weakSelf configureSections];
    }];
}

#pragma mark - UnpaidBalance

- (void)showUnpaidBalance:(RAUnpaidBalance *)unpaidBalance {
    ConfigUnpaidBalance *config = [ConfigurationManager shared].global.unpaidBalance;
    
    UnpaidBalanceViewController *vc = [[UIStoryboard storyboardWithName:@"Payment" bundle:nil] instantiateViewControllerWithIdentifier:UnpaidBalanceViewController.className];
    vc.viewModel =
    [UnpaidBalanceViewModel modelWithBalance:unpaidBalance
                               paymentMethod:self.selectedPaymentItem
                                      config:config];
    [self.navigationController pushViewController:vc animated:YES];
}

- (PaymentItem *)selectedPaymentItem {
    RARiderDataModel *rider = [RASessionManager sharedManager].currentRider;
    for (PaymentItem *item in self.paymentMethods) {
        switch (rider.preferredPaymentMethod) {
            case PaymentMethodUnspecified:
            case PaymentMethodPrimaryCreditCard:
                if (item.isCreditCard && item.card.primary.boolValue) {
                    return item;
                }
                break;
                
            case PaymentMethodApplePay:
                if (item.isApplePay) {
                    return item;
                }
                break;
                
            case PaymentMethodBevoBucks:
                if (item.isBevoBucks) {
                    return item;
                }
                break;
        }
    }
    NSAssert(YES, @"Its unexpected that a payment item is not selected");
    return nil;
}

#pragma mark - Helpers

- (void)showCardExpirationAlertIfNeeded {
    RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
    if (rider.primaryCard && [rider.primaryCard.cardExpired boolValue]) {
        [RAAlertManager showAlertWithTitle:@"" message:@"Sorry your card has expired, please select or add a valid card" options:[RAAlertOption optionWithState:StateActive]];
    }
}

- (void)showCantChangePaymentMethodAlert {
    [RAAlertManager showAlertWithTitle:[ConfigurationManager appName]
                               message:@"You can select another payment method after your trip."
                               options:[RAAlertOption optionWithState:StateActive]];
}

- (BOOL)canChangePaymentMethod {
    return ![RARideManager sharedManager].isRiding;
}

@end
