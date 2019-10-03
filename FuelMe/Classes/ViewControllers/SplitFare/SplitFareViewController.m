//
//  SplitFareViewController.m
//  Ride
//
//  Created by Roberto Abreu on 1/17/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "SplitFareViewController.h"

#import "Contact.h"
#import "DNA.h"
#import "PhoneNumberFormatter.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+PhoneUtils.h"
#import "NSString+Utils.h"
#import "SplitFareHeaderSection.h"
#import "SplitFareManager.h"
#import "SplitFareTableViewCell.h"
#import "UITextField+Helpers.h"
#import "UIColor+HexUtils.h"

#import <ContactsUI/ContactsUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SplitFareViewController() <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate>

//IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UITextField *txtContactNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@end

@implementation SplitFareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureObservers];
    [self configureUI];
}

#pragma mark - Configure UI

- (void)configureUI {
    [self.txtContactNumber addLeftPadding:14.0];
    [self.txtContactNumber addRightPadding:14.0];
    [self configureFareSplitingBottomView];
}

- (void)configureFareSplitingBottomView {
    if ([[SplitFareManager sharedManager] totalContacts] > 0) {
        [self hideNotFareSplitingView];
    } else {
        [self showNotFareSplitingView];
    }
}

- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"SplitFareHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"SplitFareSectionHeader"];
}

#pragma mark - Configure Observers

- (void)configureObservers {
    __weak SplitFareViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationSplitFareDataUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf configureFareSplitingBottomView];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - Services

- (void)sendSplitFareToContact:(Contact *)contact {
    [self showHUD];
    __weak SplitFareViewController *weakSelf = self;
    [[SplitFareManager sharedManager] sendSplitRequestToContact:contact inRide:self.rideId withCompletion:^(id responseObject, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
        } else {
            weakSelf.txtContactNumber.text = @"";
            [weakSelf enableSendButtonIfNeeded];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)sendTapped:(id)sender {
    [self.txtContactNumber resignFirstResponder];
    if (self.isFormValid) {
        NSString *phoneNumber = self.txtContactNumber.text.clearedPhoneNumber;
        Contact *contact = [Contact new];
        contact.firstName = phoneNumber;
        [contact.phoneNumbers addObject:phoneNumber];
        [self sendSplitFareToContact:contact];
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter mobile number" localized] andOptions:[RAAlertOption optionWithState:StateAll]];
    }
}

- (IBAction)showContactTapped:(id)sender {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        CNContactPickerViewController *contactsVC = [CNContactPickerViewController new];
        contactsVC.delegate = self;
        [self.navigationController presentViewController:contactsVC animated:YES completion:nil];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    static PhoneNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[PhoneNumberFormatter alloc] init];
    }
    
    NSCharacterSet *allowDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *lastPhoneInput = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:allowDigits];
    NSString *formattedPhoneInput = [formatter stringForObjectValue:lastPhoneInput];
    if (formattedPhoneInput.length > 0 && [formattedPhoneInput characterAtIndex:formattedPhoneInput.length - 1] != ')') {
        textField.text = formattedPhoneInput;
    } else {
        textField.text = lastPhoneInput;
    }

    [self enableSendButtonIfNeeded];
    return NO;
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[SplitFareManager sharedManager] numberOfsections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[SplitFareManager sharedManager] numberOfRowsForSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SplitFareHeaderSection *splitFareHeaderSection = (SplitFareHeaderSection *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SplitFareSectionHeader"];
    splitFareHeaderSection.lblSectionTitle.text = [[SplitFareManager sharedManager] titleOfHeaderInSection:section];
    
    NSString *title = [[SplitFareManager sharedManager] titleOfHeaderInSection:section];
    NSArray *numberCharacters = [title componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    if (!numberCharacters || [numberCharacters count] == 0) {
        splitFareHeaderSection.lblSectionTitle.text = title;
    } else {
        NSDictionary *baseAttributes = @{NSFontAttributeName : [UIFont fontWithName:FontTypeLight size:13.0]};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title
                                                                                             attributes:baseAttributes];
        
        NSDictionary *numberAttributes = @{NSFontAttributeName : [UIFont fontWithName:FontTypeBold size:13.0]};
        for (NSString *numberStr in numberCharacters) {
            NSRange range = [title rangeOfString:numberStr];
            [attributedString addAttributes:numberAttributes range:range];
        }
        splitFareHeaderSection.lblSectionTitle.attributedText = attributedString;
    }
    
    return splitFareHeaderSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SplitFareTableViewCell *splitFareCell = (SplitFareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"splitFareCell" forIndexPath:indexPath];
    
    SplitFare *splitFare = [[SplitFareManager sharedManager] contactForRowAtIndexPath:indexPath];
    splitFareCell.lblName.text = splitFare.riderName;
    
    NSURL *photUrl = [NSURL URLWithString:splitFare.riderPhoto];
    [splitFareCell.imgUserProfile sd_setImageWithURL:photUrl placeholderImage:[UIImage imageNamed:@"Icon-user"]];
    
    [splitFareCell.btnCancel addTarget:self action:@selector(removeSplitFare:) forControlEvents:UIControlEventTouchUpInside];
    
    return splitFareCell;
}

- (void)removeSplitFare:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        SplitFare *splitFare = [[SplitFareManager sharedManager] contactForRowAtIndexPath:indexPath];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:[NSString accessibleAlertTitle:[@"SPLIT FARE" localized]]
                                                                    message:[NSString stringWithFormat:[@"Do you want to remove the split with %@?" localized],splitFare.riderName]
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        __weak SplitFareViewController *weakSelf = self;
        UIAlertAction *yes = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showHUD];
            [[SplitFareManager sharedManager] removeSplitWithSplitID:splitFare.modelID.stringValue andCompletion:^(BOOL success) {
                [weakSelf hideHUD];
                [weakSelf reloadData];
            }];
        }];
        
        [ac addAction:[UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil]];
        [ac addAction:yes];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

#pragma mark - Contacts Delegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    Contact *newContact = [[Contact alloc] initWithContact:contact];
    [self sendSplitFareToContact:newContact];
}

#pragma mark - Helpers

- (void)showNotFareSplitingView {
    if (self.footerView.alpha != 0.0) {
        return;
    }
    
    [self.footerView setAlpha:0.0];
    [self.footerView setBounds:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 120.0)];
    [UIView animateWithDuration:0.5 animations:^{
        [self.footerView setAlpha:1.0];
    }];
}

- (void)hideNotFareSplitingView {
    [self.footerView setAlpha:0.0];
    [self.footerView setBounds:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0)];
}

- (void)enableSendButtonIfNeeded {
    BOOL shouldEnabled = self.isFormValid;
    self.btnSend.enabled = shouldEnabled;
    self.btnSend.backgroundColor = shouldEnabled ? [UIColor colorWithHex:@"#02A7F9"] : [UIColor colorWithHex:@"#B1B4BB"];
}

- (BOOL)isFormValid {
    return self.txtContactNumber.text.clearedPhoneNumber.length >= 10;
}

- (void)reloadData {
    [[SplitFareManager sharedManager] reloadDataWithRideId:self.rideId andCompletion:^(NSError *error, BOOL stopPolling) {
        if (stopPolling) {
            [[SplitFareManager sharedManager] stopPolling];
        }
    }];
}

@end
