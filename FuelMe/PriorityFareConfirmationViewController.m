//
//  PriorityFareConfirmationViewController.m
//  Ride
//
//  Created by Roberto Abreu on 3/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PriorityFareConfirmationViewController.h"

#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "PFConfirmationViewModel.h"
#import "RAEventsLongPolling.h"
#import "RAMacros.h"

#define kBtnConfirmEnabled [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1]
#define kBtnConfirmDisable [UIColor colorWithRed:177.0/255.0 green:180.0/255.0 blue:187.0/255.0 alpha:1]

@interface PriorityFareConfirmationViewController () <UITextFieldDelegate>

@property (nonatomic,weak) RACarCategoryDataModel *category;
@property (nonatomic) PFConfirmationViewModel *viewModel;

@property (nonatomic,strong) UIAlertController *surgeAlert;

@property (weak, nonatomic) IBOutlet UIView *containerInformation;
@property (weak, nonatomic) IBOutlet UIView *containerConfirmation;

//Information Screen Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSurgeFactorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopOfFairDetailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopOfAcceptButton;

//Confirmation Screen Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLblConfirmationTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLineTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLblTypeTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintFirstTextFieldTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintFirstTextFieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintFirstTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLblXBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnConfirmationTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLblNormalFareTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnOkHeight;

@end

@interface PriorityFareConfirmationViewController (SurgeUpdateEvent)

- (void)observeEvents;
- (void)unobserveEvents;
- (void)surgeAreaHasBeenUpdated;

@end

@implementation PriorityFareConfirmationViewController

- (id)initWithCategory:(RACarCategoryDataModel*)category {
    if (self = [super init]) {
        self.category = category;
        
        [self observeEvents];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.viewModel = [PFConfirmationViewModel viewModelWithCategory:self.category];
}

- (void)setViewModel:(PFConfirmationViewModel *)viewModel {
    _viewModel = viewModel;
    [self updateTextWithViewModel:viewModel];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];

    if (IS_IPHONE4 || IS_IPHONE4S) {
        
        //Information Screen
        self.constraintSurgeFactorHeight.constant = 40.0;
        self.constraintTopOfFairDetailLabel.constant = 10.0;
        self.constraintTopOfAcceptButton.constant = 15.0;
        [self.lblSurgeFactor setFont:[UIFont fontWithName:FontTypeLight size:30.0]];
        
        //Confirmation Scren
        self.constraintLblConfirmationTop.constant = 10.0;
        self.constraintLineTop.constant = 8.0;
        self.constraintLblTypeTop.constant = 8.0;
        self.constraintFirstTextFieldTop.constant = 8.0;
        self.constraintFirstTextFieldWidth.constant = 50.0;
        self.constraintFirstTextFieldHeight.constant = 50.0;
        
        self.constraintLblNormalFareTop.constant = 8.0;
        self.constraintBtnOkHeight.constant = 40.0;
        self.constraintBtnConfirmationTop.constant = 8.0;
        self.constraintLblXBottom.constant = -14.0;
        
        self.lblConfirmationTitle.font = [UIFont fontWithName:FontTypeRegular size:13.0];
        self.lblNumberToType.font = [UIFont fontWithName:FontTypeLight size:12.0];
        self.lblDot.font = [UIFont fontWithName:FontTypeRegular size:27.0];
        self.txtFirstNumber.font = [UIFont fontWithName:FontTypeLight size:30.0];
        self.txtSecondNumber.font = [UIFont fontWithName:FontTypeLight size:30.0];
        self.lblNormalFareTitle.font = [UIFont fontWithName:FontTypeLight size:10.0];
    }
}

- (void)dealloc{
    DBLog(@"dealloc priority fare VC");
    [self unobserveEvents];
}

- (void)updateTextWithViewModel:(PFConfirmationViewModel *)viewModel {
    self.title = viewModel.title;
    //
    //  Information
    //
    self.lblSurgeFactor.text           = viewModel.surgeFactorText;
    self.lblMinimumFare.attributedText = viewModel.minimumFare;
    self.lblMin.attributedText         = viewModel.min;
    self.lblMile.attributedText        = viewModel.mile;
    //
    //  Confirmation SubScreen
    //
    self.lblNumberToType.text          = viewModel.numberToTypeDescription;
    self.txtFirstNumber.placeholder    = viewModel.wholeNumberToType;
    self.txtSecondNumber.placeholder   = viewModel.decimalToType;
    self.txtFirstNumber.text  = nil;
    self.txtSecondNumber.text = nil;
    [self updateBtnConfirmation];
}

- (IBAction)acceptFare:(id)sender {
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close-1"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelRequest:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.containerInformation.alpha = 0;
        self.containerConfirmation.alpha = 1;
    } completion:^(BOOL finished) {
        [self.txtFirstNumber becomeFirstResponder];
    }];
    
}

- (IBAction)cancelRequest:(id)sender {
    __weak PriorityFareConfirmationViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.handler){
            weakSelf.handler(NO);
        }
    }];
}

#pragma mark - Confirmation SubScreen

- (IBAction)confirmationAccepted:(id)sender {
    __weak PriorityFareConfirmationViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.handler){
            weakSelf.handler(YES);
        }
    }];
}

- (void)updateBtnConfirmation {
    BOOL isValid = [self.viewModel isValidWholeNumber:self.txtFirstNumber.text
                                           andDecimal:self.txtSecondNumber.text];
    [self setBtnConfirmationEnabled:isValid];
}

- (void)setBtnConfirmationEnabled:(BOOL)isEnabled {
    self.btnConfirmation.enabled = isEnabled;
    self.btnConfirmation.backgroundColor = isEnabled ? kBtnConfirmEnabled : kBtnConfirmDisable;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.background = [UIImage imageNamed:@"bgFieldActive"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.background = [UIImage imageNamed:@"bgFieldDisable"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtFirstNumber) {
        [self.txtSecondNumber becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([@"\n" isEqualToString:string]) {
        return NO;
    }
    
    if (textField == self.txtSecondNumber) {
        if (self.txtSecondNumber.text.length != self.viewModel.decimalToType.length || [string isEqualToString:@""]){
            self.txtSecondNumber.text = [self.txtSecondNumber.text stringByReplacingCharactersInRange:range withString:string];
        }
        
        [self updateBtnConfirmation];
        return NO;
    }
    
    textField.text = string;
    if (![string isEqualToString:@""]) {
        [self textFieldShouldReturn:textField];
    }
    
    [self updateBtnConfirmation];
    return NO;
}


@end

#pragma mark - Surge Update Event

@implementation PriorityFareConfirmationViewController (SurgeUpdateEvent)

- (void)observeEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(surgeAreaHasBeenUpdated)
                                                 name:kSurgeAreaUpdateNotification
                                               object:nil];
}

- (void)unobserveEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSurgeAreaUpdateNotification
                                                  object:nil];
}

- (void)surgeAreaHasBeenUpdated {
    PFConfirmationViewModel *newVM = [PFConfirmationViewModel viewModelWithCategory:self.category];
    BOOL didChange = newVM.surgeFactor.doubleValue != self.viewModel.surgeFactor.doubleValue;
    if (didChange) {
        self.viewModel = newVM;
        
        if (self.surgeAlert) {
            [self.surgeAlert dismissViewControllerAnimated:YES completion:nil];
        }
        
        RAAlertOption *options = [RAAlertOption optionWithState:StateAll andShownOption:Overlap];
        if (self.category.hasPriority) {
            self.surgeAlert = [RAAlertManager showAlertWithTitle:nil message:[@"Surge has been updated. Please review it." localized] options:options];
        } else {
            __weak __typeof__(self) weakself = self;
            [options addAction:[RAAlertAction actionWithTitle:[[@"CANCEL" localized] capitalizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
                [weakself cancelRequest:nil];
            }]];
            [options addAction:[RAAlertAction actionWithTitle:[@"Request Ride" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                [weakself confirmationAccepted:nil];
            }]];
            
            self.surgeAlert = [RAAlertManager showAlertWithTitle:[@"Surge Disabled" localized] message:[@"Surge has been disabled. Do you want to request the ride?" localized] options:options];
        }
    }
}
@end
