//
//  RatingViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/30/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RatingViewController.h"

#import "ErrorReporter.h"
#import "RAMacros.h"
#import "RAPaymentProviderInformationPopup.h"
#import "RARideAPI.h"
#import "RatingViewModel.h"
#import "UnratedRideManager.h"
#import "UIColor+HexUtils.h"
#import "HCSStarRatingView.h"
#import <Appirater/Appirater.h>
#import <BFRImageViewer/BFRImageViewer-umbrella.h>
#import <SDWebImage/UIImageView+WebCache.h>

//Tip Special Index
#define kNoTipIndex    0
#define kOtherTipIndex 4

//Colors
#define charcoalGreyTwo  [UIColor colorWithHex:@"#2C323C"]
#define disabledGrey     [UIColor colorWithHex:@"#D9DBDC"]
#define borderGrey       [UIColor colorWithHex:@"#DFDFDF"]

//Tip const
static CGFloat const kTipHeightCollapsed = 0.0;
static CGFloat const kTipHeightExpanded = 55.0;
static CGFloat const kTipHeightExpandedWithOtherField = 112.0;

//Provider Container const
static CGFloat const kProviderContainerCollapsed =  0.0;
static CGFloat const kProviderContainerExpanded  = 60.0;

@interface RatingViewController () <RatingViewModelDelegate, UITextFieldDelegate>

//IBOulets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgSnapSHot;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mapActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *imgDriverRatingView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentsTitle;
@property (weak, nonatomic) IBOutlet UITextView *textViewComments;
@property (weak, nonatomic) IBOutlet UISegmentedControl *btnTip;
@property (weak, nonatomic) IBOutlet UITextField *tfOtherAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoCreditInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblRideCost;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmitRating;
@property (weak, nonatomic) IBOutlet UIView *otherView;

//Payment Provider Outlets
@property (weak, nonatomic) IBOutlet UIImageView *imgPaymentProvider;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderName;
@property (weak, nonatomic) IBOutlet UISwitch *paymentProviderSwitch;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTipViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContainerPaymentProviderHeight;

//Properties
@property (nonatomic) RAPaymentProviderInformationPopup *paymentProviderPopup;
@property (nonatomic) NSTimer *updateScreenTimer;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) CGPoint defaultScrollViewContentOffset;

//Animator
@property (nonatomic) BFRImageTransitionAnimator *imageViewAnimator;
@end

@interface RatingViewController (UpdateScreenTimer)

- (void)startTimer;
- (void)stopTimer;
- (void)updateScreenTimerFired;
- (void)disableTipControl;

@end

@interface RatingViewController (TextViewDelegate) <UITextViewDelegate>

@end

@interface RatingViewController (PaymentProvider)

- (void)configurePaymentProviderUI;
- (IBAction)paymentProviderInformationTapped:(id)sender;

@end

@implementation RatingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel.delegate = self;
    self.imageViewAnimator = [BFRImageTransitionAnimator new];
    [self configureKeyboardObservers];
    [self configureDefaults];
    [self configureObservers];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tgr];
    [self.view setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //FIX: RA-avoid reload every time
    if (!self.imageURL) {
        DBLog(@"opening rating with rideID:%@", self.viewModel.temporaryRideID);
        [self updateWithUnratedRide];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupScrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)setupScrollView {
    UIEdgeInsets scrollViewInsets = UIEdgeInsetsZero;
    scrollViewInsets.top = MAX((CGRectGetHeight(self.scrollView.bounds) - CGRectGetHeight(self.containerView.bounds)) / 2.0, 0);
    scrollViewInsets.bottom = MAX((CGRectGetHeight(self.scrollView.bounds) - CGRectGetHeight(self.containerView.bounds)) / 2.0, 0);
    [self.scrollView setContentSize:self.containerView.bounds.size];
    [self.scrollView setContentInset:scrollViewInsets];
}

- (void)configureDefaults {
    [self setRateSubmitBtnEnabled:NO];

    //Input Accessory View
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.view action:@selector(endEditing:)];
    [btnDone setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:FontTypeLight size:14.5]} forState:UIControlStateNormal];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [toolbar setItems:@[flexibleSpace, btnDone]];
    
    //Configure Input Accessory View
    self.textViewComments.inputAccessoryView = toolbar;
    self.tfOtherAmount.inputAccessoryView = toolbar;
    
    //Segmented Control
    UIFont *font = [UIFont fontWithName:FontTypeLight size:13];
    NSDictionary *attNormal   = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : charcoalGreyTwo};
    [self.btnTip setTitleTextAttributes:attNormal forState:UIControlStateNormal];
    NSDictionary *attSelected = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.btnTip setTitleTextAttributes:attSelected forState:UIControlStateSelected];
    if (@available(iOS 13.0, *)) {
        self.btnTip.selectedSegmentTintColor = UIColor.azureBlue;
    }
}

- (void)updateMapForRideID:(NSString *)rideID {
    [RARideAPI getMapForRide:rideID withCompletion:^(NSURL *mapURL, NSError *error) {
        __weak __typeof__(self) weakself = self;
        if (mapURL) {
            self.imageURL = mapURL;
            [self.mapActivityIndicatorView startAnimating];
            [self.imgSnapSHot sd_setImageWithURL:self.imageURL placeholderImage:[UIImage imageNamed:@"map_placeholder"] options:SDWebImageHighPriority completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [weakself.mapActivityIndicatorView stopAnimating];
            }];
        } else if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:nil];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            userInfo[@"rideIDwithoutImage"] = rideID;
            userInfo[@"issue"] = error;
            NSError *error = [NSError errorWithDomain:@"URLInvalidImage" code:-5693 userInfo:userInfo];
            [ErrorReporter recordError:error withDomainName:URLInvalidImage];
            
        } else {
            //RA-9484 When server is creating the map, the request returns nil object, retrying after few seconds shows the map
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself updateMapForRideID:rideID];
            });
        }
    }];
}

- (void)updateWithUnratedRide {
    [self updateMapForRideID:self.viewModel.temporaryRideID];
    self.lblCommentsTitle.text = self.viewModel.commentTitle;
    self.lblPromoCreditInfo.text = self.viewModel.summaryDescription;
    self.lblRideCost.text = self.viewModel.totalLabel;
    [self.imgDriverRatingView sd_setImageWithURL:self.viewModel.driverPhotoURL];
    
    [self configurePaymentProviderUI];
    
    if ([self.viewModel shouldShowTip]) {
        self.constraintTipViewHeight.constant = kTipHeightExpanded;
    } else {
        [self disableTipControl];
        self.constraintTipViewHeight.constant = kTipHeightCollapsed;
    }
    
    [self.view layoutIfNeeded];
    [self configureAccessibility];
    [self startTimer];
}

- (void)setRateSubmitBtnEnabled:(BOOL)enabled {
    //  allow submit rating without tip for blind people
    if (UIAccessibilityIsVoiceOverRunning()) {
        enabled = YES;
    }
    self.btnSubmitRating.enabled = enabled;
    self.btnSubmitRating.backgroundColor = enabled ? UIColor.azureBlue : disabledGrey;
}

#pragma mark - Observers

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    __weak RatingViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kDidSignoutNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)appDidEnterBackgroundNotification:(NSNotification *)notification {
    [self stopTimer];
}

- (void)appWillEnterForegroundNotification:(NSNotification *)notification {
    if (self.viewModel.shouldShowTip || self.viewModel.shouldShowPaymentProvider) {
        [self startTimer];
    }
}

#pragma mark - RatingViewModelDelegate

- (void)ratingViewModelDidUpdate {
    [self setRateSubmitBtnEnabled:[self.viewModel canEnableSubmitButton]];
}

- (void)ratingViewModelDidClearTextField {
    self.tfOtherAmount.text = nil;
    [self.tfOtherAmount becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)showFullScreenMap:(UITapGestureRecognizer *)sender {
    [self navigateToFullScreen:self.imgSnapSHot];
}

- (IBAction)showDriverPhoto:(UITapGestureRecognizer *)sender {
    [self navigateToFullScreen:self.imgDriverRatingView];
}

- (void)navigateToFullScreen:(UIImageView *)imageView {
    CGRect innerFrame = [self.view convertRect:imageView.frame fromView:imageView.superview];
    self.imageViewAnimator.imageOriginFrame = innerFrame;
    self.imageViewAnimator.animatedImageContainer = imageView;
    self.imageViewAnimator.animatedImage = imageView.image;
    self.imageViewAnimator.desiredContentMode = imageView.contentMode;
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[imageView.image]];
    imageVC.enableDoneButton = NO;
    imageVC.transitioningDelegate = self.imageViewAnimator;
    [self presentViewController:imageVC animated:YES completion:nil];
}

- (IBAction)paymentProviderSwitchChanged:(UISwitch *)sender {
    self.viewModel.isPaymentProviderSwitchOn = sender.isOn;
}

- (IBAction)btnTipValueChanged:(UISegmentedControl *)sender {
    self.viewModel.selectedTipIndex = sender.selectedSegmentIndex;
    [self setTFTipVisible:(sender.selectedSegmentIndex == kOtherTipIndex)];
    
    for (int i = 0; i < [sender.subviews count]; i++) {
        UIControl *component = [sender.subviews objectAtIndex:i];
        if ([component respondsToSelector:@selector(isSelected)]) {
            UIColor *tintColor = [component isSelected] ? UIColor.azureBlue : borderGrey;
            [component setTintColor:tintColor];
        }
    }
}

- (void)setTFTipVisible:(BOOL)isVisible {
    self.tfOtherAmount.isAccessibilityElement = isVisible;
    self.constraintTipViewHeight.constant = isVisible ? kTipHeightExpandedWithOtherField : kTipHeightExpanded;
    [self.view layoutIfNeeded];
    [self setupScrollView];
    
    if (isVisible) {
        [self.tfOtherAmount becomeFirstResponder];
    } else {
        if (self.tfOtherAmount.isFirstResponder) {
            [self.tfOtherAmount resignFirstResponder];
        }
    }
}

- (IBAction)starValueChanged:(HCSStarRatingView*)sender {
    self.viewModel.rating = sender.value;
}

- (IBAction)btnSubmitRatingTapped {
    [self.viewModel setPaymentMethod];
    [self.viewModel setComment:self.textViewComments.text];
    
    __weak __typeof__(self) weakself = self;
    [self.viewModel submitRatingWithCompletion:^(float userRating) {
        if (weakself.ratingSelectedBlock) {
            weakself.ratingSelectedBlock(userRating);
        }
        [weakself dismissViewControllerAnimated:YES completion:^{
            if (userRating == 5) {
                [Appirater tryToShowPrompt];
            }
            if (self.viewModel.isFromDeeplink) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"rideaustindispatcher://completedRideReload"]];
            }
        }];
    }];
}

#pragma mark - Keyboard observers

- (void)configureKeyboardObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.defaultScrollViewContentOffset = self.scrollView.contentOffset;
    NSDictionary *keyboardInfo = [notification userInfo];
    CGFloat endKeyboardY = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    if ([self.tfOtherAmount isFirstResponder]) {
        CGRect otherTipTFRect = [self.scrollView convertRect:self.tfOtherAmount.frame fromView:self.tfOtherAmount];
        CGFloat offsetY = otherTipTFRect.origin.y - (endKeyboardY - 8 - self.tfOtherAmount.bounds.size.height);
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
    } else if ([self.textViewComments isFirstResponder]){
        CGRect commentsTVRect = [self.scrollView convertRect:self.textViewComments.frame fromView:self.textViewComments];
        CGFloat offsetY = commentsTVRect.origin.y - (endKeyboardY - 8 - self.textViewComments.bounds.size.height);
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.scrollView setContentOffset:self.defaultScrollViewContentOffset];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *tipValue = [textField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    if (tipValue.length > 0) {
        [self.viewModel setUserTip:tipValue];
    } else {
        if (self.btnTip.selectedSegmentIndex == kOtherTipIndex) {
            self.btnTip.selectedSegmentIndex = kNoTipIndex;
            [self btnTipValueChanged:self.btnTip];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = @"$";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self validatedString:string.uppercaseString withRange:range]) {
        NSString *updatedString = [[textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString] stringByReplacingOccurrencesOfString:@"$" withString:@""];
        BOOL isMax = updatedString.length >= self.viewModel.maxTipLength;
        NSString *limitedString = isMax ? [updatedString substringToIndex:self.viewModel.maxTipLength] : updatedString;
        textField.text = [NSString stringWithFormat:@"$%@",limitedString];
        if (isMax) {
            if (self.viewModel.maxTipValue != nil) {
                if (limitedString.doubleValue > self.viewModel.maxTipValue.doubleValue) {
                    textField.text = [NSString stringWithFormat:@"$%@",self.viewModel.maxTipValue.stringValue];
                } else {
                    [textField endEditing:YES];
                }
            } else {
                [textField endEditing:YES];
            }
        }
    }

    return NO;
}

#pragma mark UITextField Validation

- (BOOL)validatedString:(NSString *)replacementString withRange:(NSRange)range{
    NSString *possibleString = [self.tfOtherAmount.text stringByReplacingCharactersInRange:range withString:replacementString];
    if (([self.tfOtherAmount.text isEqualToString:@"$"] && [replacementString isEqualToString:@""]) || ![possibleString hasPrefix:@"$"]) {
        return NO;
    }
    
    NSString *validCharacters = self.validCharacters;
    if (!validCharacters || [validCharacters isEqualToString:@""]) {
        return YES;
    }
    
    BOOL isBackspace = [replacementString isEqualToString:@""];
    BOOL isStringNotValid = [validCharacters rangeOfString:replacementString].location == NSNotFound;
    return isBackspace || !isStringNotValid;
}

- (NSString *)validCharacters {
    return @"1234567890";
}

#pragma mark - Configure Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (void)configureAccessibility {
    self.imgSnapSHot.accessibilityLabel = @"Show map in fullscreen";
    self.imgSnapSHot.accessibilityTraits = UIAccessibilityTraitButton;
    
    self.imgDriverRatingView.accessibilityLabel = @"Show driver in fullscreen";
    self.imgDriverRatingView.accessibilityTraits = UIAccessibilityTraitButton;
    
    self.textViewComments.accessibilityLabel = @"Comments field";
    self.lblRideCost.accessibilityLabel = [NSString stringWithFormat:@"Total fare: %@", self.lblRideCost.text];
    
    //Tip btn / TextField
    self.tfOtherAmount.accessibilityLabel = @"Other Amount";
    self.tfOtherAmount.accessibilityHint = @"Enter the amount for the tip";
    self.tfOtherAmount.isAccessibilityElement = NO;
    self.btnSubmitRating.accessibilityLabel = @"Submit Rating";
}

@end

#pragma mark - Update Screen Timer

@implementation RatingViewController (UpdateScreenTimer)

- (void)startTimer {
    [self stopTimer];
    self.updateScreenTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateScreenTimerFired) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (self.updateScreenTimer) {
        [self.updateScreenTimer invalidate];
        self.updateScreenTimer = nil;
    }
}

- (void)updateScreenTimerFired {
    [self hidePaymentProviderViewIfNeeded];
    [self hideTipViewIfNeeded];
    
    if (!self.viewModel.shouldShowPaymentProvider && !self.viewModel.shouldShowTip) {
        [self stopTimer];
    }
}

- (void)hideTipViewIfNeeded {
    if (!self.viewModel.shouldShowTip && self.constraintTipViewHeight.constant == kTipHeightExpanded) {
        [self disableTipControl];
        self.constraintTipViewHeight.constant = kTipHeightCollapsed;
        [self.view layoutIfNeeded];
    }
}

- (void)disableTipControl {
    if (self.btnTip.selectedSegmentIndex == UISegmentedControlNoSegment) {
        self.btnTip.selectedSegmentIndex = 0;
        [self btnTipValueChanged:self.btnTip];
    }
}

- (void)hidePaymentProviderViewIfNeeded {
    if (!self.viewModel.shouldShowPaymentProvider && self.constraintContainerPaymentProviderHeight.constant == kProviderContainerExpanded) {
        [self.paymentProviderSwitch setOn:NO animated:YES];
        self.viewModel.isPaymentProviderSwitchOn = NO;
        self.constraintContainerPaymentProviderHeight.constant = kProviderContainerCollapsed;
        [self.view layoutIfNeeded];
    }
}

@end

#pragma mark - TextView Delegate

@implementation RatingViewController (TextViewDelegate)

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *updatedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (updatedString.length > self.viewModel.maxCommentLength) {
        textView.text = [updatedString substringWithRange:NSMakeRange(0, self.viewModel.maxCommentLength)];
        return NO;
    }
    return YES;
}

@end

#pragma mark - Payment Provider

@implementation RatingViewController (PaymentProvider)

- (void)configurePaymentProviderUI {
    if ([self.viewModel shouldShowPaymentProvider]) {
        RAPaymentProvider *provider = self.viewModel.paymentProvider;
        [self.imgPaymentProvider sd_setImageWithURL:provider.logoUrl placeholderImage:nil];
        self.lblProviderName.text = [NSString stringWithFormat:@"Pay with %@", provider.name];
        self.paymentProviderSwitch.hidden = provider.switchHidden;
        self.paymentProviderSwitch.on = [RASessionManager sharedManager].currentRider.preferredPaymentMethod == PaymentMethodBevoBucks;
        self.viewModel.isPaymentProviderSwitchOn = self.paymentProviderSwitch.on;
        self.constraintContainerPaymentProviderHeight.constant = kProviderContainerExpanded;
        [self.view layoutIfNeeded];
    }
}

- (IBAction)paymentProviderInformationTapped:(id)sender {
    RAPaymentProvider *provider = self.viewModel.paymentProvider;
    self.paymentProviderPopup = [RAPaymentProviderInformationPopup paymentProviderWithPhotoURL:provider.logoUrl name:provider.name detail:provider.detail];
    [self.paymentProviderPopup show];
}

@end
